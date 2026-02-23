#!/usr/bin/env python3

import argparse
import os

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.lines as mlines
import matplotlib.transforms as mtransforms
from xdsl_smt.utils.synthesizer_utils.parse_result import parse_eval_result
from pathlib import Path

def parse_int_list(s: str) -> list[int]:
    return [int(x) for x in s.split(",")]

def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "input", type=str, help="input to the specification file"
    )
    arg_parser.add_argument(
        "output", nargs='?', type=str, help="Output folder", default="scatter-plot"
    )
    arg_parser.add_argument(
        "--bitwidth", nargs='?', type=parse_int_list, help="Bitwidth", default=[1,2,3,4]
    )


def main() -> None:
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    root = Path(args.input)
    output_dir = Path(args.output)

    if not root.is_dir():
        print(f"{root} is not a valid directory")
        return

    output_dir.mkdir(parents=True, exist_ok=True)
    EvalResult.init_bw_settings(set(args.bitwidth), set(), set())
    RESULT_PREFIX="KnownBits_"

    bitwidth_to_scatter:dict[int, list[list[float]]] = {}
    # Iterate over direct subfolders
    for subdir in root.iterdir():
        basename = os.path.basename(subdir)
        if not subdir.is_dir() or not basename.startswith(RESULT_PREFIX):
            continue

        res_file = subdir / "pattern_res.txt"

        if res_file.exists() and basename:
            with open(res_file, "r") as fin:
                content = fin.read()
            evalResult= parse_eval_result(content)
            for i, result in enumerate(evalResult):
                for per_bit_res in result.per_bit_res:
                    if per_bit_res.bitwidth not in bitwidth_to_scatter:
                        bitwidth_to_scatter[per_bit_res.bitwidth] = [[], []]
                    bitwidth_to_scatter[per_bit_res.bitwidth][i].append(per_bit_res.get_exact_prop())
            print(res_file)

            # do_something(res_file)

    for bitwidth, values in bitwidth_to_scatter.items():
        #plt.figure()
        fig, ax = plt.subplots()
        ax.scatter(values[1], values[0])
        line = mlines.Line2D([0, 1], [0, 1], color='red')
        transform = ax.transAxes
        line.set_transform(transform)
        ax.add_line(line)
        ax.set_ylabel('The precision of composite transfer function')
        ax.set_xlabel('The precision of sequential version')
        ax.set_title('Bitwidth' + str(bitwidth))
        plt.savefig(output_dir/("Bitwidth " +str(bitwidth) + ".png"), dpi=300)




if __name__ == "__main__":
    main()
