from argparse import ArgumentParser, Namespace, ArgumentDefaultsHelpFormatter
from pathlib import Path
from multiprocessing import Pool


from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitRes
from xdsl_smt.eval_engine.eval import AbstractDomain, setup_eval, eval_final
from xdsl.dialects.func import FuncOp
from xdsl_smt.utils.synthesizer_utils.random import Random
from xdsl_smt.cli.synth_transfer import print_to_cpp, get_helper_funcs, parse_file
from xdsl_smt.cli.arg_parser import int_triple, int_tuple


def register_all_arguments() -> Namespace:
    ap = ArgumentParser(
        prog="eval_final", formatter_class=ArgumentDefaultsHelpFormatter
    )

    ap.add_argument("transfer_functions", type=Path, help="path to transfer functions")
    ap.add_argument("solution_path", type=Path, help="path to the solution")
    ap.add_argument("-random_file", type=str, help="file with random numbers")
    ap.add_argument("-random_seed", type=int, help="specify the random seed")
    ap.add_argument(
        "-lbw",
        nargs="*",
        type=int,
        default=[1, 2, 3, 4],
        help="Bitwidths to evaluate exhaustively",
    )
    ap.add_argument(
        "-mbw",
        nargs="*",
        type=int_tuple,
        default=[],
        help="Bitwidths to evaluate sampled lattice elements exhaustively",
    )
    ap.add_argument(
        "-hbw",
        nargs="*",
        type=int_triple,
        default=[],
        help="Bitwidths to sample the lattice and abstract values with",
    )

    return ap.parse_args()


def run(
    domain: AbstractDomain,
    lbws: list[int],
    mbws: list[tuple[int, int]],
    hbws: list[tuple[int, int, int]],
    input_path: Path,
    solution_path: Path,
    random_seed: int | None,
    op_name: str,
) -> tuple[EvalResult, EvalResult, EvalResult, EvalResult]:
    assert min(lbws, default=4) >= 4 or domain != AbstractDomain.IntegerModulo

    _, helpers = get_helper_funcs(input_path, domain)
    sol_module = parse_file(solution_path)

    random = Random(random_seed)
    random_seed = random.randint(0, 1_000_000) if random_seed is None else random_seed

    solution_helpers: list[FuncOp] = []
    solution: FuncOp | None = None
    for func in sol_module.ops:
        if isinstance(func, FuncOp):
            if func.sym_name.data == "solution":
                solution = func
            else:
                solution_helpers.append(func)

    assert solution is not None, "No solution function found in solution file"

    helper_funcs_cpp = helpers.to_cpp() + [
        print_to_cpp(func) for func in solution_helpers
    ]

    data_dir = setup_eval(
        domain, lbws, mbws, hbws, random_seed, "\n".join(helper_funcs_cpp)
    )

    res = eval_final(
        data_dir,
        solution.sym_name.data,
        print_to_cpp(solution),
        op_name,
        helper_funcs_cpp,
        domain,
    )

    assert len(res) == 4

    return res[0], res[1], res[2], res[3]


def run_wrapper(x: tuple[Namespace, AbstractDomain, Path, Path, str]):
    return run(
        domain=x[1],
        lbws=x[0].lbw,
        mbws=x[0].mbw,
        hbws=x[0].hbw,
        input_path=x[2],
        solution_path=x[3],
        random_seed=x[0].random_seed,
        op_name=x[4],
    )


def _get_dist_table(
    top: EvalResult,
    synth: EvalResult,
    llvm: EvalResult,
    meet: EvalResult,
    mbs: list[int],
    hbs: list[int],
) -> str:
    s = ""
    use_llvm = sum(x.exacts for x in llvm.per_bit_res) != 0

    s += "           ######  Dists  ######           \n"
    s += "bw  | Top     | Synth   | LLVM    | Meet   \n"
    s += "----|---------|---------|---------|--------\n"
    for t_pb, s_pb, l_pb, m_pb in zip(
        top.per_bit_res, synth.per_bit_res, llvm.per_bit_res, meet.per_bit_res
    ):
        p = "+" if t_pb.bitwidth in mbs else ""
        a = "*" if t_pb.bitwidth in hbs else ""
        bw = f"{t_pb.bitwidth}" + a + p
        llvm_dist = l_pb.dist if use_llvm else "N/A"
        meet_dist = m_pb.dist if use_llvm else "N/A"
        s += f"{bw:<4}| {t_pb.dist:<7} | {s_pb.dist:<7} | {llvm_dist:<7} | {meet_dist:<7}\n"

    return s


def _get_exact_table(
    top: EvalResult,
    synth: EvalResult,
    llvm: EvalResult,
    meet: EvalResult,
    mbs: list[int],
    hbs: list[int],
) -> str:
    def fmt(x: PerBitRes) -> str:
        p = x.get_exact_prop()
        return f"{p*100:05.2f}%" if p < 1 else f"{p*100:05.1f}%"

    s = ""
    use_llvm = sum(x.exacts for x in llvm.per_bit_res) != 0

    s += "        ######  Exacts  ######         \n"
    s += "bw | Top    | Synth  | LLVM   | Meet   \n"
    s += "---|--------|--------|--------|--------\n"
    for t_pb, s_pb, l_pb, m_pb in zip(
        top.per_bit_res, synth.per_bit_res, llvm.per_bit_res, meet.per_bit_res
    ):
        p = "+" if t_pb.bitwidth in mbs else ""
        a = "*" if t_pb.bitwidth in hbs else ""
        bw = f"{t_pb.bitwidth}" + a + p
        llvm_exact = fmt(l_pb) if use_llvm else "N/A"
        meet_exact = fmt(m_pb) if use_llvm else "N/A"

        s += f"{bw:<4}| {fmt(t_pb)} | {fmt(s_pb)} | {llvm_exact:<6} | {meet_exact:<6}\n"

    return s


def main() -> None:
    args = register_all_arguments()

    assert args.transfer_functions.is_dir()

    if args.solution_path.is_dir():
        solution_files = list(args.solution_path.iterdir())
    else:
        solution_files = [args.solution_path]

    inputs: list[tuple[Namespace, AbstractDomain, Path, Path, str]] = []
    for solution_dir in solution_files:
        if not solution_dir.is_dir():
            continue

        solution_path = solution_dir.joinpath("solution.mlir")
        domain_str, op = solution_dir.name.split("_")
        domain = AbstractDomain[domain_str]

        if not solution_path.exists():
            print(f"No solution file for: {domain} {op}")
            continue

        input_path = args.transfer_functions.joinpath(f"{op}.mlir")
        assert input_path.exists()

        inputs.append((args, domain, input_path, solution_path, op))

    with Pool() as p:
        data = p.map(run_wrapper, inputs)

    mbs = [x[0] for x in args.mbw]
    hbs = [x[0] for x in args.hbw]

    for (_, domain, _, _, op), (top_r, synth_r, llvm_r, meet_r) in zip(inputs, data):
        print()
        print(
            f"#################################   {domain} {op}   ############################"
        )
        dists = _get_dist_table(top_r, synth_r, llvm_r, meet_r, mbs, hbs)
        exacts = _get_exact_table(top_r, synth_r, llvm_r, meet_r, mbs, hbs)
        zipped_tables = zip(dists.split("\n"), exacts.split("\n"))

        s = "\n".join([f"{d}   ||   {e}" for d, e in zipped_tables][:-1])
        print(s)


if __name__ == "__main__":
    main()
