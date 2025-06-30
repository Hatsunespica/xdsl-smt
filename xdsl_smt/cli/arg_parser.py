from argparse import (
    ArgumentParser,
    Namespace,
    ArgumentDefaultsHelpFormatter,
    FileType,
    ArgumentTypeError,
)
from xdsl_smt.eval_engine.eval import AbstractDomain
from pathlib import Path


def _int_tuple(s: str) -> tuple[int, int]:
    try:
        items = s.split(",")
        if len(items) != 2:
            raise ValueError
        return (int(items[0]), int(items[1]))
    except Exception:
        raise ArgumentTypeError(
            f"Invalid tuple format: '{s}'. Expected format: int,int"
        )


def register_arguments(prog: str) -> Namespace:
    ap = ArgumentParser(prog=prog, formatter_class=ArgumentDefaultsHelpFormatter)

    if prog == "synth_transfer":
        ap.add_argument(
            "transfer_functions", type=Path, help="path to transfer function"
        )
        ap.add_argument(
            "-random_file", type=FileType("r"), help="file for preset operation picks"
        )
        ap.add_argument(
            "-domain",
            type=str,
            choices=[str(x) for x in AbstractDomain],
            required=True,
            help="Abstract Domain to evaluate",
        )

    ap.add_argument(
        "-outputs_folder",
        type=Path,
        help="Output folder for logs",
        default=Path("outputs"),
    )
    ap.add_argument("-random_seed", type=int, help="seed for synthesis")
    ap.add_argument(
        "-program_length",
        type=int,
        help="length of synthed program",
        default=28,
    )
    ap.add_argument(
        "-total_rounds",
        type=int,
        help="number of rounds the synthesizer should run",
        default=1500,
    )
    ap.add_argument(
        "-num_programs",
        type=int,
        help="number of programs that run every round",
        default=100,
    )
    ap.add_argument(
        "-inv_temp",
        type=int,
        help="Inverse temperature for MCMC. The larger the value is, the lower the probability of accepting a program with a higher cost.",
        default=200,
    )
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
        type=_int_tuple,
        default=[],
        help="Bitwidths to evaluate sampled lattice elements exhaustively",
    )
    ap.add_argument(
        "-hbw",
        nargs="*",
        type=_int_tuple,
        default=[(16, 100)],
        help="Bitwidths to sample the lattice and abstract values with",
    )
    ap.add_argument(
        "-solution_size", type=int, help="size of the solution set", default=0
    )
    ap.add_argument(
        "-num_iters",
        type=int,
        help="number of iterations for the synthesizer",
        default=10,
    )
    ap.add_argument(
        "-no_weighted_dsl",
        dest="weighted_dsl",
        action="store_false",
        help="Disable learning weights for each DSL operation from previous for future iterations",
    )
    ap.set_defaults(weighted_dsl=True)
    ap.add_argument(
        "-condition_length", type=int, help="length of synthd abduction", default=10
    )
    ap.add_argument(
        "-num_abd_procs",
        type=int,
        help="number of mcmc processes used for abduction. Must be less than num_programs",
        default=30,
    )
    ap.add_argument(
        "-num_unsound_candidates",
        type=int,
        help="number of unsound candidates considered for abduction",
        default=15,
    )
    ap.add_argument("-quiet", action="store_true")

    return ap.parse_args()
