from multiprocessing import Pool
from json import dump
from argparse import Namespace
from pathlib import Path

from xdsl_smt.cli.synth_spec_transfer import run
from xdsl_smt.cli.arg_parser import register_arguments
from xdsl_smt.eval_engine.eval import AbstractDomain
from xdsl_smt.utils.synthesizer_utils.log_utils import setup_loggers
from typing import Any

all_test_names = [
    "4_1002118.mlir",
    #"1_348667.mlir",
    #"2_215733.mlir",
    #"3_186886.mlir",
    #"4_177254.mlir",
    #"5_158932.mlir",
   # "6_99954.mlir",
   # "7_70582.mlir",
   # "8_69592.mlir",
   # "9_69209.mlir",
   # "10_68804.mlir",
   # "11_68233.mlir",
    #"12_67972.mlir",
    #"13_67254.mlir",
    #"14_63673.mlir",
    #"15_63561.mlir",
    #"16_63514.mlir",
    #"17_61456.mlir",
    #"18_61336.mlir",
    #"19_59469.mlir",
    #"20_57396.mlir",
    #"21_56882.mlir",
    #"22_55378.mlir",
    #"23_52397.mlir",
    #"24_51547.mlir",
    #"25_50993.mlir",
    #"26_50028.mlir",
    #"27_49446.mlir",
    #"28_45613.mlir",
    #"29_45284.mlir",
    #"30_45081.mlir",
    #'31_42777.mlir',
    #'32_40704.mlir',
    #'33_40414.mlir',
    #'34_39350.mlir',
    #'35_36625.mlir',
    #'36_36504.mlir',
    #'37_36349.mlir',
    #'38_36120.mlir',
    #'39_35662.mlir',
    '40_35485.mlir',
    '41_34412.mlir',
    '42_34293.mlir',
    '43_34198.mlir',
    '44_33529.mlir',
    #'45_32922.mlir',
    #'46_32455.mlir',
    #'47_32395.mlir',
    #'48_32386.mlir',
    #'49_31677.mlir',
    #'50_30842.mlir'
    ]



ucr_test_names = [
    # "Abds.mlir",
    "Abdu.mlir",
    "Add.mlir",
    # "AddNsw.mlir",
    "AddNswNuw.mlir",
    "AddNuw.mlir",
    "And.mlir",
    # "AshrExact.mlir",
    # "Ashr.mlir",
    # "AvgCeilS.mlir",
    "AvgCeilU.mlir",
    # "AvgFloorS.mlir",
    "AvgFloorU.mlir",
    "LshrExact.mlir",
    "Lshr.mlir",
    # "Mods.mlir",
    "Modu.mlir",
    "Mul.mlir",
    # "MulNsw.mlir",
    "MulNswNuw.mlir",
    "MulNuw.mlir",
    "Or.mlir",
    # "SaddSat.mlir",
    # "SdivExact.mlir",
    # "Sdiv.mlir",
    "Shl.mlir",
    # "ShlNsw.mlir",
    "ShlNswNuw.mlir",
    "ShlNuw.mlir",
    # "Smax.mlir",
    # "Smin.mlir",
    # "SmulSat.mlir",
    # "SshlSat.mlir",
    # "SsubSat.mlir",
    "Sub.mlir",
    # "SubNsw.mlir",
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

scr_test_names = [name for name in all_test_names if name not in ucr_test_names]

kb_representative_test_names = [
    "Add.mlir",
    "AddNsw.mlir",
    "AddNuw.mlir",
    "And.mlir",
    "Mul.mlir",
    "AvgFloorU.mlir",
    "Lshr.mlir",
    "Shl.mlir",
    "UdivExact.mlir",
    "Udiv.mlir",
    "Umax.mlir",
]


kb_not_best_test_names = [
    "Mul.mlir",
    "MulNsw.mlir",
    "MulNswNuw.mlir",
    "MulNuw.mlir",
    "Udiv.mlir",
    "Sdiv.mlir",
    "Modu.mlir",
    "Mods.mlir",
    "UdivExact.mlir",
    "Add.mlir",
    "Umax.mlir",
    "And.mlir",
    "AvgFloorU.mlir",
]
# Some best tests are also included (Add, Umax, And, AvgFloorU)

cr_not_best_test_names = [
    "And.mlir",
    "Xor.mlir",
    "Mul.mlir",
    "Modu.mlir",
    "Shl.mlir",
    "Lshr.mlir",
    "Ashr.mlir",
    "Umax.mlir",
    "Add.mlir",
]
# Some best tests are also included (Umax, Add)

EXTRA_DATA_PATH=Path("tests").joinpath("synth", "NewPatternsData")

def check_extra_data_path(tf_path: Path) -> str:
    basename = tf_path.stem
    data_path = EXTRA_DATA_PATH / f"{basename}.tsv"
    if data_path.exists():
        return str(data_path.resolve())
    return ""

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
        data_path = check_extra_data_path(tf_path)
        #if data_path == "":
        #    raise ValueError("Didn't find data file")

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
            dsl_file=args.dsl_file if args.dsl_file else None,
            spec_path=args.spec,
            external_data_path=data_path
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
    start_dir = Path("tests").joinpath("synth", "NewPatterns")

    if not args.outputs_folder.exists():
        args.outputs_folder.mkdir(parents=True, exist_ok=True)
    else:
        raise FileExistsError(
            f'Output folder "{args.outputs_folder}" already exists. Please remove it or choose a different one.'
        )

    kb_inputs = [
        (x.split(".")[0], AbstractDomain.KnownBits, start_dir.joinpath(x), args)
        for x in all_test_names
    ]

    ucr_inputs = [
        #(x.split(".")[0], AbstractDomain.UConstRange, start_dir.joinpath(x), args)
        #for x in ucr_test_names
    ]

    scr_inputs = [
        #(x.split(".")[0], AbstractDomain.SConstRange, start_dir.joinpath(x), args)
        #for x in scr_test_names
    ]

    with Pool(4) as p:
        data = p.map(synth_run, kb_inputs + ucr_inputs + scr_inputs)
    #data=[]
    #for item in  kb_inputs + ucr_inputs + scr_inputs:
    #    data.append(synth_run(item))

    with open(args.outputs_folder.joinpath("data.json"), "w") as f:
        dump(data, f, indent=2)


if __name__ == "__main__":
    main()
