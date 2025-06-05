from pathlib import Path
from argparse import ArgumentParser, Namespace
from multiprocessing import Pool


from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from xdsl_smt.eval_engine.eval import AbstractDomain, setup_eval, eval_transfer_func
from xdsl.dialects.func import FuncOp
from xdsl_smt.utils.synthesizer_utils.random import Random
from xdsl_smt.cli.synth_transfer import print_to_cpp, get_helper_funcs, parse_file


def register_all_arguments() -> Namespace:
    arg_parser = ArgumentParser()

    arg_parser.add_argument(
        "transfer_functions", type=Path, help="path to transfer functions"
    )
    arg_parser.add_argument("solution_path", type=Path, help="path to the solution")
    arg_parser.add_argument("-random_file", type=str, help="file with random numbers")
    arg_parser.add_argument("-random_seed", type=int, help="specify the random seed")
    arg_parser.add_argument(
        "-min_bitwidth",
        type=int,
        default=1,
        help="Specify the minimum bitwidth of the evaluation engine",
    )
    arg_parser.add_argument(
        "-max_bitwidth",
        type=int,
        default=4,
        help="max bitwidth of the evaluation engine",
    )
    arg_parser.add_argument(
        "-num_random_tests",
        type=int,
        default=None,
        help="Specify the number of random test inputs at higher bitwidth. 0 by default",
    )

    return arg_parser.parse_args()


def run(
    domain: AbstractDomain,
    bitwidth: int,
    min_bitwidth: int,
    input_path: Path,
    solution_path: Path,
    num_random_tests: int | None = None,
    random_seed: int | None = None,
) -> EvalResult:
    assert min_bitwidth >= 4 or domain != AbstractDomain.IntegerModulo
    EvalResult.get_max_dis = domain.max_dist

    _, helpers = get_helper_funcs(input_path, domain, False)
    sol_module = parse_file(solution_path)

    random = Random(random_seed)
    random_seed = random.randint(0, 1_000_000) if random_seed is None else random_seed
    samples = (random_seed, num_random_tests) if num_random_tests is not None else None

    solution_helpers: list[FuncOp] = []
    solution: FuncOp | None = None
    for func in sol_module.ops:
        if isinstance(func, FuncOp):
            if func.sym_name.data == "solution":
                solution = func
            else:
                solution_helpers.append(func)
    assert solution is not None, "No solution function is found in solution file"

    helper_funcs_cpp = helpers.to_cpp() + [
        print_to_cpp(func) for func in solution_helpers
    ]

    data_dir = setup_eval(
        domain, bitwidth, min_bitwidth, samples, "\n".join(helper_funcs_cpp)
    )

    res = eval_transfer_func(
        data_dir,
        [solution.sym_name.data],
        [print_to_cpp(solution)],
        [],
        [],
        helper_funcs_cpp,
        domain,
    )

    return res[0]


def run_wrapper(x: tuple[Namespace, AbstractDomain, Path, Path, str]):
    return run(
        domain=x[1],
        bitwidth=x[0].max_bitwidth,
        min_bitwidth=x[0].min_bitwidth,
        input_path=x[2],
        solution_path=x[3],
        num_random_tests=x[0].num_random_tests,
        random_seed=x[0].random_seed,
    )


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

    print("\nResults:")
    for (_, domain, _, _, op), r in zip(inputs, data):
        print(f"{domain} {op}")
        percent = r.per_bit[r.max_bit].exacts / r.per_bit[r.max_bit].all_cases * 100
        dist = r.per_bit[r.max_bit].dist
        print(f"Exact: {percent:.4f}%, Dist: {dist}")


if __name__ == "__main__":
    main()
