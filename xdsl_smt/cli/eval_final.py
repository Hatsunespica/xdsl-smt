from argparse import ArgumentParser, Namespace, ArgumentDefaultsHelpFormatter
from pathlib import Path

from multiprocessing import Pool
from itertools import zip_longest


from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitRes
from xdsl_smt.eval_engine.eval import AbstractDomain, rp_final
from xdsl.dialects.func import FuncOp
from xdsl_smt.utils.synthesizer_utils.random import Random
from xdsl_smt.cli.synth_transfer import print_to_cpp, get_helper_funcs, parse_file
from xdsl_smt.cli.arg_parser import int_triple, int_tuple
from xdsl.dialects.builtin import ModuleOp


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
        default=[],
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


def get_solution(mod: ModuleOp) -> tuple[list[FuncOp], FuncOp]:
    solution_helpers: list[FuncOp] = []
    solution: FuncOp | None = None
    for func in mod.ops:
        if isinstance(func, FuncOp):
            if func.sym_name.data == "solution":
                solution = func
            else:
                solution_helpers.append(func)

    assert solution is not None, "No solution function found in solution file"

    return solution_helpers, solution


def replacer(x: str | list[str] | None, dom: str) -> str:
    if isinstance(x, list):
        x = "\n".join(x)
    if not x:
        return ""

    d = [
        "getTop",
        "getInstanceConstraint",
        "getConstraint",
        "meet",
    ]

    x = x.replace(d[0], f"{dom}_{d[0]}")
    x = x.replace(d[1], f"{dom}_{d[1]}")
    x = x.replace(d[2], f"{dom}_{d[2]}")
    x = x.replace(d[3], f"{dom}_{d[3]}")

    return x


def run(
    lbws: list[int],
    mbws: list[tuple[int, int]],
    hbws: list[tuple[int, int, int]],
    input_path: Path,
    solution_paths: tuple[Path, Path | None, Path | None],
    random_seed: int | None,
    op_name: str,
) -> tuple[
    EvalResult,
    EvalResult,
    EvalResult,
    EvalResult,
    EvalResult,
    EvalResult,
]:
    kb_sol_path, ucr_sol_path, scr_sol_path = solution_paths

    _, kb_helpers = get_helper_funcs(input_path, AbstractDomain.KnownBits)
    _, ucr_helpers = get_helper_funcs(input_path, AbstractDomain.UConstRange)
    _, scr_helpers = get_helper_funcs(input_path, AbstractDomain.SConstRange)
    kb_sol_module = parse_file(kb_sol_path)
    ucr_sol_module = parse_file(ucr_sol_path) if ucr_sol_path else None
    scr_sol_module = parse_file(scr_sol_path) if scr_sol_path else None

    random = Random(random_seed)
    random_seed = random.randint(0, 1_000_000) if random_seed is None else random_seed

    kb_sol_help, kb_solution = get_solution(kb_sol_module)
    ucr_sol_help, ucr_solution = (
        get_solution(ucr_sol_module) if ucr_sol_module else (None, None)
    )
    scr_sol_help, scr_solution = (
        get_solution(scr_sol_module) if scr_sol_module else (None, None)
    )

    kb_solution_cpp = print_to_cpp(kb_solution).replace("solution", "kb_solution")
    ucr_solution_cpp = (
        print_to_cpp(ucr_solution).replace("solution", "ucr_solution")
        if ucr_solution
        else None
    )
    scr_solution_cpp = (
        print_to_cpp(scr_solution).replace("solution", "scr_solution")
        if scr_solution
        else None
    )
    kb_help_cpp = [
        print_to_cpp(x).replace("partial", "partial_kb") for x in kb_sol_help
    ]
    ucr_help_cpp = (
        [print_to_cpp(x).replace("partial", "partial_ucr") for x in ucr_sol_help]
        if ucr_sol_help
        else None
    )
    scr_help_cpp = (
        [print_to_cpp(x).replace("partial", "partial_scr") for x in scr_sol_help]
        if scr_sol_help
        else None
    )
    kb_domain_cpp = [replacer(x, "kb") for x in kb_helpers.to_cpp_no_cnc()]
    ucr_domain_cpp = [replacer(x, "ucr") for x in ucr_helpers.to_cpp_no_cnc()]
    scr_domain_cpp = [replacer(x, "scr") for x in scr_helpers.to_cpp_no_cnc()]
    conc_cpp = kb_helpers.conc_to_cpp()

    all_src = [
        conc_cpp,
        "\n".join(kb_domain_cpp),
        "\n".join(ucr_domain_cpp),
        "\n".join(scr_domain_cpp),
        replacer(kb_help_cpp, "kb"),
        replacer(ucr_help_cpp, "ucr"),
        replacer(scr_help_cpp, "scr"),
        replacer(kb_solution_cpp, "kb"),
        replacer(ucr_solution_cpp, "ucr"),
        replacer(scr_solution_cpp, "scr"),
    ]

    res = rp_final(
        lbws,
        mbws,
        hbws,
        random_seed,
        "kb_solution",
        "ucr_solution" if ucr_sol_path else "ucr_getTop",
        "scr_solution" if scr_sol_path else "scr_getTop",
        op_name,
        "\n".join(all_src),
    )

    assert len(res) == 6

    return (
        res[0],
        res[1],
        res[2],
        res[3],
        res[4],
        res[5],
    )


def run_wrapper(
    x: tuple[Namespace, Path, tuple[Path, Path, Path], str],
):
    return run(
        lbws=x[0].lbw,
        mbws=x[0].mbw,
        hbws=x[0].hbw,
        input_path=x[1],
        solution_paths=x[2],
        random_seed=x[0].random_seed,
        op_name=x[3],
    )


def _get_dist_table(
    top: EvalResult,
    synth: EvalResult,
    red: EvalResult,
    mbs: list[int],
    hbs: list[int],
) -> str | None:
    s = ""

    s += "           ######  Dists  ######            \n"
    s += "bw  | Cases   | Top     | Synth   | Reduced \n"
    s += "----|---------|---------|---------|---------\n"
    for t_pb, s_pb, red_pb in zip(top.per_bit_res, synth.per_bit_res, red.per_bit_res):
        p = "+" if t_pb.bitwidth in mbs else ""
        a = "*" if t_pb.bitwidth in hbs else ""
        bw = f"{t_pb.bitwidth}" + a + p
        s += f"{bw:<4}| {t_pb.all_cases:<7} | {t_pb.dist:<7} | {s_pb.dist:<7} | {red_pb.dist:<7} \n"

    return s


def _get_exact_table(
    top: EvalResult,
    synth: EvalResult,
    red: EvalResult,
    mbs: list[int],
    hbs: list[int],
) -> str:
    def fmt(x: PerBitRes) -> str:
        p = x.get_exact_prop()
        return f"{p*100:05.2f}%" if p < 1 else f"{p*100:05.1f}%"

    s = ""

    s += "     ######  Exacts  #####     \n"
    s += "bw  | Top    | Synth  | Reduced\n"
    s += "----|--------|--------|--------\n"
    for t_pb, s_pb, red_pb in zip(
        top.per_bit_res,
        synth.per_bit_res,
        red.per_bit_res,
    ):
        if t_pb.bitwidth in hbs:
            continue
        p = "+" if t_pb.bitwidth in mbs else ""
        bw = f"{t_pb.bitwidth}" + p

        s += f"{bw:<4}| {fmt(t_pb)} | {fmt(s_pb)} | {fmt(red_pb):<6}\n"

    return s


def main() -> None:
    args = register_all_arguments()

    assert args.transfer_functions.is_dir()

    if args.solution_path.is_dir():
        solution_files = list(args.solution_path.iterdir())
    else:
        solution_files = [args.solution_path]

    inputs: list[
        tuple[Namespace, Path, tuple[Path, Path | None, Path | None], str]
    ] = []
    for solution_dir in solution_files:
        if "UConstRange" in str(solution_dir) or "SConstRange" in str(solution_dir):
            continue
        if not solution_dir.is_dir():
            continue

        kb_solution_path = solution_dir.joinpath("solution.mlir")
        ucr_solution_path = Path(
            str(kb_solution_path).replace("KnownBits", "UConstRange")
        )
        scr_solution_path = Path(
            str(kb_solution_path).replace("KnownBits", "SConstRange")
        )

        _, op = solution_dir.name.split("_")

        if not kb_solution_path.exists():
            print(f"No solution file for: kb {op}")
            continue

        if not ucr_solution_path.exists():
            ucr_solution_path = None

        if not scr_solution_path.exists():
            scr_solution_path = None

        input_path = args.transfer_functions.joinpath(f"{op}.mlir")
        assert input_path.exists()

        inputs.append(
            (
                args,
                input_path,
                (kb_solution_path, ucr_solution_path, scr_solution_path),
                op,
            )
        )

    inputs = sorted(inputs, key=lambda x: x[3])

    # tODO
    with Pool() as p:
        data = p.map(run_wrapper, inputs)
    # data = list(map(run_wrapper, inputs))

    mbs = [x[0] for x in args.mbw]
    hbs = [x[0] for x in args.hbw]

    for (_, _, _, op), (
        kb_top,
        kb_syn,
        _kb_llvm,
        _kb_meet,
        kb_red_syn,
        _kb_red_meet,
    ) in zip(inputs, data):
        dists = _get_dist_table(
            kb_top,
            kb_syn,
            kb_red_syn,
            mbs,
            hbs,
        )
        exacts = _get_exact_table(
            kb_top,
            kb_syn,
            kb_red_syn,
            mbs,
            hbs,
        )
        if not dists:
            continue
        print()
        print(
            f"#################################   KnownBits {op}   ############################"
        )
        zipped_tables = zip_longest(dists.split("\n"), exacts.split("\n"), fillvalue="")

        s = "\n".join([f"{d}   ||   {e}" for d, e in zipped_tables][:-1])
        print(s)
        print()

        s = "\n".join([f"{d}   ||   {e}" for d, e in zipped_tables][:-1])
        print(s)


if __name__ == "__main__":
    main()
