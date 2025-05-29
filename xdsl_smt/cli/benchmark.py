from math import nan
from multiprocessing import Pool
from json import dump
from argparse import Namespace
from pathlib import Path
from shutil import rmtree

from xdsl_smt.cli.synth_transfer import run
from xdsl_smt.cli.arg_parser import register_arguments
from xdsl_smt.eval_engine.eval import AbstractDomain
from xdsl_smt.utils.synthesizer_utils.log_utils import setup_loggers


kb_test_names = [
    "knownBitsAbds.mlir",
    "knownBitsAbdu.mlir",
    "knownBitsAddConstRHS.mlir",
    "knownBitsAdd.mlir",
    "knownBitsAddNsw.mlir",
    "knownBitsAddNswNuw.mlir",
    "knownBitsAddNuw.mlir",
    "knownBitsAndConstRHS.mlir",
    "knownBitsAnd.mlir",
    "knownBitsAshrConstRHS.mlir",
    "knownBitsAshrExact.mlir",
    "knownBitsAshr.mlir",
    "knownBitsAvgCeilS.mlir",
    "knownBitsAvgCeilU.mlir",
    "knownBitsAvgFloorS.mlir",
    "knownBitsAvgFloorU.mlir",
    "knownBitsLshrConstRHS.mlir",
    "knownBitsLshrExact.mlir",
    "knownBitsLshr.mlir",
    "knownBitsModsConstRHS.mlir",
    "knownBitsMods.mlir",
    "knownBitsModuConstRHS.mlir",
    "knownBitsModu.mlir",
    "knownBitsMulConstRHS.mlir",
    "knownBitsMul.mlir",
    "knownBitsOrConstRHS.mlir",
    "knownBitsOr.mlir",
    "KnownBitsSaddSat.mlir",
    "knownBitsSdivConstRHS.mlir",
    "knownBitsSdivExact.mlir",
    "knownBitsSdiv.mlir",
    "knownBitsShlConstRHS.mlir",
    "knownBitsShl.mlir",
    "knownBitsShlNsw.mlir",
    "knownBitsShlNswNuw.mlir",
    "knownBitsShlNuw.mlir",
    "knownBitsSmax.mlir",
    "knownBitsSmin.mlir",
    "KnownBitsSsubSat.mlir",
    "knownBitsSubConstRHS.mlir",
    "knownBitsSub.mlir",
    "knownBitsSubNsw.mlir",
    "knownBitsSubNswNuw.mlir",
    "knownBitsSubNuw.mlir",
    "KnownBitsUaddSat.mlir",
    "knownBitsUdivConstRHS.mlir",
    "knownBitsUdivExact.mlir",
    "knownBitsUdiv.mlir",
    "knownBitsUmax.mlir",
    "knownBitsUmin.mlir",
    "KnownBitsUsubSat.mlir",
    "knownBitsXorConstRHS.mlir",
    "knownBitsXor.mlir",
]

cr_test_names = [
    "integerRangeAdd.mlir",
    "integerRangeAddNsw.mlir",
    "integerRangeAddNswNuw.mlir",
    "integerRangeAddNuw.mlir",
    "integerRangeAnd.mlir",
    "integerRangeAshrExact.mlir",
    "integerRangeAshr.mlir",
    "integerRangeLshrExact.mlir",
    "integerRangeLshr.mlir",
    "integerRangeMods.mlir",
    "integerRangeModu.mlir",
    "integerRangeMul.mlir",
    "integerRangeMulNsw.mlir",
    "integerRangeMulNswNuw.mlir",
    "integerRangeMulNuw.mlir",
    "integerRangeOr.mlir",
    "integerRangeSaddSat.mlir",
    "integerRangeSdivExact.mlir",
    "integerRangeSdiv.mlir",
    "integerRangeShl.mlir",
    "integerRangeShlNsw.mlir",
    "integerRangeShlNswNuw.mlir",
    "integerRangeShlNuw.mlir",
    "integerRangeSmax.mlir",
    "integerRangeSmin.mlir",
    "integerRangeSmulSat.mlir",
    "integerRangeSshlSat.mlir",
    "integerRangeSsubSat.mlir",
    "integerRangeSub.mlir",
    "integerRangeSubNsw.mlir",
    "integerRangeSubNswNuw.mlir",
    "integerRangeSubNuw.mlir",
    "integerRangeUaddSat.mlir",
    "integerRangeUdivExact.mlir",
    "integerRangeUdiv.mlir",
    "integerRangeUmax.mlir",
    "integerRangeUmin.mlir",
    "integerRangeUmulSat.mlir",
    "integerRangeUshlSat.mlir",
    "integerRangeUsubSat.mlir",
    "integerRangeXor.mlir",
]


def synth_run(
    x: tuple[str, AbstractDomain, Path, Namespace],
) -> dict[str, float | str]:
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
            max_bitwidth=args.max_bitwidth,
            min_bitwidth=args.min_bitwidth,
            solution_size=args.solution_size,
            num_iters=args.num_iters,
            condition_length=args.condition_length,
            num_abd_procs=args.num_abd_procs,
            num_random_tests=args.num_random_tests,
            random_seed=args.random_seed,
            random_number_file=None,
            total_rounds=args.total_rounds,
            transfer_functions=open(tf_path, "r"),
            weighted_dsl=args.weighted_dsl,
            outputs_folder=output_folder,
        )

        return {
            "Domain": str(domain),
            "Function": func_name,
            "Sound Proportion": res.get_sound_prop() * 100,
            "Exact Proportion": res.get_exact_prop() * 100,
            "Seed": args.random_seed,
            "Notes": "",
        }
    except Exception as e:
        return {
            "Domain": str(domain),
            "Function": func_name,
            "Sound Proportion": nan,
            "Exact Proportion": nan,
            "Seed": args.random_seed,
            "Notes": f"Run was terminated: {e}",
        }


def main() -> None:
    args = register_arguments("benchmark")
    start_dir = Path("tests").joinpath("synth")

    if not args.outputs_folder.exists():
        args.outputs_folder.mkdir(parents=True, exist_ok=True)
    else:
        raise FileExistsError(
            f"Output folder \"{args.outputs_folder}\" already exists. Please remove it or choose a different one."
        )
    kb_inputs = [
        (
            x.split("Bits")[1].split(".")[0],
            AbstractDomain.KnownBits,
            start_dir.joinpath("KnownBits", x),
            args,
        )
        for x in kb_test_names
    ]

    cr_inputs = [
        (
            x.split("Range")[1].split(".")[0],
            AbstractDomain.ConstantRange,
            start_dir.joinpath("ConstantRange", x),
            args,
        )
        for x in cr_test_names
    ]

    with Pool() as p:
        data = p.map(synth_run, kb_inputs + cr_inputs)

    with open(args.outputs_folder.joinpath("data.json"), "w") as f:
        dump(data, f, indent=2)


if __name__ == "__main__":
    main()
