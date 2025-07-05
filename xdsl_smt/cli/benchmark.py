from multiprocessing import Pool
from json import dump
from argparse import Namespace
from pathlib import Path

from xdsl_smt.cli.synth_transfer import run
from xdsl_smt.cli.arg_parser import register_arguments
from xdsl_smt.eval_engine.eval import AbstractDomain
from xdsl_smt.utils.synthesizer_utils.log_utils import setup_loggers
from typing import Any


all_test_names = [
    "Abds.mlir",
    "Abdu.mlir",
    "Add.mlir",
    "AddNsw.mlir",
    "AddNswNuw.mlir",
    "AddNuw.mlir",
    "And.mlir",
    "AshrExact.mlir",
    "Ashr.mlir",
    "AvgCeilS.mlir",
    "AvgCeilU.mlir",
    "AvgFloorS.mlir",
    "AvgFloorU.mlir",
    "LshrExact.mlir",
    "Lshr.mlir",
    "Mods.mlir",
    "Modu.mlir",
    "Mul.mlir",
    "MulNsw.mlir",
    "MulNswNuw.mlir",
    "MulNuw.mlir",
    "Or.mlir",
    "SaddSat.mlir",
    "SdivExact.mlir",
    "Sdiv.mlir",
    "Shl.mlir",
    "ShlNsw.mlir",
    "ShlNswNuw.mlir",
    "ShlNuw.mlir",
    "Smax.mlir",
    "Smin.mlir",
    "SmulSat.mlir",
    "SshlSat.mlir",
    "SsubSat.mlir",
    "Sub.mlir",
    "SubNsw.mlir",
    "SubNswNuw.mlir",
    "SubNuw.mlir",
    "UaddSat.mlir",
    "UdivExact.mlir",
    "Udiv.mlir",
    "Umax.mlir",
    "Umin.mlir",
    "UmulSat.mlir",
    "UshlSat.mlir",
    "UsubSat.mlir",
    "Xor.mlir",
]


im_tests = [
    "AddNsw.mlir",
    "AddNswNuw.mlir",
    "AddNuw.mlir",
    "Mods.mlir",
    "Modu.mlir",
    "Mul.mlir",
    "MulNsw.mlir",
    "MulNswNuw.mlir",
    "MulNuw.mlir",
    "SdivExact.mlir",
    "Sdiv.mlir",
    "SmulSat.mlir",
    "UaddSat.mlir",
    "UdivExact.mlir",
    "Udiv.mlir",
    "UmulSat.mlir",
]


def synth_run(
    x: tuple[str, AbstractDomain, Path, Namespace],
) -> dict[str, Any]:
    func_name = x[0]
    domain = x[1]
    tf_path = x[2]
    args = x[3]

    print(f"Running {domain} {func_name}")

    try:
        output_folder = args.outputs_folder.joinpath(f"{domain}_{func_name}")
        output_folder.mkdir()
        logger = setup_loggers(output_folder, not args.quiet)
        [logger.info(f"{k}: {v}") for k, v in vars(args).items()]

        res = run(
            logger=logger,
            domain=domain,
            num_programs=args.num_programs,
            program_length=args.program_length,
            inv_temp=args.inv_temp,
            lbws=args.lbw,
            mbws=args.mbw,
            hbws=args.hbw,
            solution_size=args.solution_size,
            num_iters=args.num_iters,
            condition_length=args.condition_length,
            num_abd_procs=args.num_abd_procs,
            random_seed=args.random_seed,
            random_number_file=None,
            total_rounds=args.total_rounds,
            transfer_functions=tf_path,
            weighted_dsl=args.weighted_dsl,
            num_unsound_candidates=args.num_unsound_candidates,
            outputs_folder=output_folder,
        )

        return {
            "Domain": str(domain),
            "Function": func_name,
            "Per Bit Result": [
                {
                    "Bitwidth": per_bit_res.bitwidth,
                    "Sound Proportion": per_bit_res.get_sound_prop() * 100,
                    "Exact Proportion": per_bit_res.get_exact_prop() * 100,
                    "Distance": per_bit_res.dist,
                }
                for per_bit_res in res.per_bit_res
            ],
            "Seed": args.random_seed,
        }
    except Exception as e:
        return {
            "Domain": str(domain),
            "Function": func_name,
            "Seed": args.random_seed,
            "Notes": f"Run was terminated: {e}",
        }


def main() -> None:
    args = register_arguments("benchmark")
    start_dir = Path("tests").joinpath("synth", "Operations")

    if not args.outputs_folder.exists():
        args.outputs_folder.mkdir(parents=True, exist_ok=True)
    else:
        raise FileExistsError(
            f'Output folder "{args.outputs_folder}" already exists. Please remove it or choose a different one.'
        )

    im_inputs = [
        (x.split(".")[0], AbstractDomain.IntegerModulo, start_dir.joinpath(x), args)
        for x in im_tests
    ]

    with Pool() as p:
        data = p.map(synth_run, im_inputs)

    with open(args.outputs_folder.joinpath("data.json"), "w") as f:
        dump(data, f, indent=2)


if __name__ == "__main__":
    main()
