from os import path, listdir, remove
from math import nan
from multiprocessing import Pool
from json import dump
from argparse import Namespace
from pathlib import Path

from xdsl_smt.cli.synth_transfer import run
from xdsl_smt.cli.arg_parser import register_arguments
from xdsl_smt.eval_engine.eval import AbstractDomain
from xdsl_smt.utils.synthesizer_utils.log_utils import setup_loggers


def rm_r(dir: Path):
    try:
        files = listdir(dir)
        for file in files:
            file_path = dir.joinpath(file)
            if path.isfile(file_path):
                remove(file_path)
    except OSError:
        print(f"Error occurred while deleting files in {dir}")


def setup_outputs(domain: AbstractDomain, func: str, outputs: Path) -> Path:
    if not outputs.is_dir():
        outputs.mkdir()

    output_folder = outputs.joinpath(f"{domain}_{func}")
    if output_folder.is_dir():
        rm_r(output_folder)
    else:
        output_folder.mkdir()

    return output_folder


def synth_run(
    x: tuple[str, AbstractDomain, Path, Namespace],
) -> dict[str, float | str]:
    func_name = x[0]
    domain = x[1]
    tf_path = x[2]
    args = x[3]

    try:
        output_folder = setup_outputs(domain, func_name, args.outputs_folder)
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

    start_dir = path.join("tests", "synth")
    xfer_funcs = {
        (AbstractDomain.KnownBits, "Add"): "knownBitsAdd.mlir",
        (AbstractDomain.KnownBits, "And"): "knownBitsAnd.mlir",
        (AbstractDomain.KnownBits, "Ashr"): "knownBitsAshr.mlir",
        (AbstractDomain.KnownBits, "Lshr"): "knownBitsLshr.mlir",
        (AbstractDomain.KnownBits, "Mods"): "knownBitsMods.mlir",
        (AbstractDomain.KnownBits, "Modu"): "knownBitsModu.mlir",
        (AbstractDomain.KnownBits, "Mul"): "knownBitsMul.mlir",
        (AbstractDomain.KnownBits, "Or"): "knownBitsOr.mlir",
        (AbstractDomain.KnownBits, "Sdiv"): "knownBitsSdiv.mlir",
        (AbstractDomain.KnownBits, "Shl"): "knownBitsShl.mlir",
        (AbstractDomain.KnownBits, "Udiv"): "knownBitsUdiv.mlir",
        (AbstractDomain.KnownBits, "Xor"): "knownBitsXor.mlir",
        (AbstractDomain.ConstantRange, "Add"): "integerRangeAdd.mlir",
        (AbstractDomain.ConstantRange, "And"): "integerRangeAnd.mlir",
        (AbstractDomain.ConstantRange, "Ashr"): "integerRangeAshr.mlir",
        (AbstractDomain.ConstantRange, "Lshr"): "integerRangeLshr.mlir",
        (AbstractDomain.ConstantRange, "Mods"): "integerRangeMods.mlir",
        (AbstractDomain.ConstantRange, "Modu"): "integerRangeModu.mlir",
        (AbstractDomain.ConstantRange, "Mul"): "integerRangeMul.mlir",
        (AbstractDomain.ConstantRange, "Or"): "integerRangeOr.mlir",
        (AbstractDomain.ConstantRange, "Sdiv"): "integerRangeSdiv.mlir",
        (AbstractDomain.ConstantRange, "Shl"): "integerRangeShl.mlir",
        (AbstractDomain.ConstantRange, "Udiv"): "integerRangeUdiv.mlir",
        (AbstractDomain.ConstantRange, "Xor"): "integerRangeXor.mlir",
    }

    def get_path(x: AbstractDomain) -> str:
        return "integerRange" if x == AbstractDomain.ConstantRange else "knownBits"

    xfer_funcs = {
        k: path.join(start_dir, get_path(k[0]), v) for k, v in xfer_funcs.items()
    }

    inputs = [
        (func_name, domain, Path(xfer_func_fname), args)
        for (domain, func_name), xfer_func_fname in xfer_funcs.items()
    ]

    with Pool() as p:
        data = p.map(synth_run, inputs)

    with open(args.outputs_folder.joinpath("data.json"), "w") as f:
        dump(data, f, indent=2)


if __name__ == "__main__":
    main()
