from argparse import ArgumentParser, Namespace, ArgumentDefaultsHelpFormatter, FileType
from xdsl_smt.eval_engine.eval import AbstractDomain
from pathlib import Path


def register_arguments(prog: str) -> Namespace:
    ap = ArgumentParser(prog=prog, formatter_class=ArgumentDefaultsHelpFormatter)
    MIN_BITWIDTH = 1
    MAX_BITWIDTH = 4
    PROGRAM_LENGTH = 40
    CONDITION_LENGTH = 6
    NUM_PROGRAMS = 100
    TOTAL_ROUNDS = 10000
    INV_TEMP = 200
    SOLUTION_SIZE = 0
    NUM_ITERS = 100
    NUM_ABD_PROCS = 0
    OUTPUT_FOLDER = Path("outputs")
    NUM_UNSOUND_CANDIDATES = 15

    if prog == "synth_transfer":
        ap.add_argument(
            "transfer_functions", type=FileType("r"), help="path to transfer function"
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

    if prog == "benchmark":
        pass

    ap.add_argument(
        "-outputs_folder",
        type=Path,
        help="Output folder for logs",
        default=OUTPUT_FOLDER,
    )
    ap.add_argument("-random_seed", type=int, help="seed for synthesis")
    ap.add_argument(
        "-program_length",
        type=int,
        help="length of synthed program",
        default=PROGRAM_LENGTH,
    )
    ap.add_argument(
        "-total_rounds",
        type=int,
        help="number of rounds the synthesizer should run",
        default=TOTAL_ROUNDS,
    )
    ap.add_argument(
        "-num_programs",
        type=int,
        help="number of programs that run every round",
        default=NUM_PROGRAMS,
    )
    ap.add_argument(
        "-inv_temp",
        type=int,
        help="Inverse temperature for MCMC. The larger the value is, the lower the probability of accepting a program with a higher cost.",
        default=INV_TEMP,
    )
    ap.add_argument(
        "-min_bitwidth",
        type=int,
        help="min bitwidth for the evaluation engine",
        default=MIN_BITWIDTH,
    )
    ap.add_argument(
        "-max_bitwidth",
        type=int,
        help="max bitwidth for the evaluation engine",
        default=MAX_BITWIDTH,
    )
    ap.add_argument(
        "-solution_size",
        type=int,
        help="size of the solution set",
        default=SOLUTION_SIZE,
    )
    ap.add_argument(
        "-num_iters",
        type=int,
        help="number of iterations for the synthesizer",
        default=NUM_ITERS,
    )
    ap.add_argument(
        "-weighted_dsl",
        action="store_true",
        help="Learn weights for each DSL operations from previous for future iterations",
    )
    ap.add_argument(
        "-condition_length",
        type=int,
        help="the length of synthesized abduction",
        default=CONDITION_LENGTH,
    )
    ap.add_argument(
        "-num_abd_procs",
        type=int,
        help="number of mcmc processes used for abduction. Must be less than num_programs",
        default=NUM_ABD_PROCS,
    )
    ap.add_argument(
        "-num_random_tests",
        type=int,
        help="number of random test inputs at higher bitwidth",
    )
    ap.add_argument(
        "-num_unsound_candidates",
        type=int,
        help="number of unsound candidates considered for abduction",
        default=NUM_UNSOUND_CANDIDATES,
    )
    ap.add_argument("-quiet", action="store_true")

    return ap.parse_args()
