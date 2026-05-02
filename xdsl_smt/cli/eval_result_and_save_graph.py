#!/usr/bin/env python3

import argparse

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
import matplotlib.pyplot as plt
import numpy as np

from xdsl_smt.utils.synthesizer_utils.parse_result import parse_eval_result


def parse_int_list(s: str) -> list[int]:
    return [int(x) for x in s.split(",")]

def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "input", type=str, help="input to the specification file"
    )
    arg_parser.add_argument(
        "figure_path", nargs='?', type=str, help="Saved figure path", default="result.png"
    )
    arg_parser.add_argument(
        "--bitwidth", nargs='?', type=parse_int_list, help="Bitwidth", default=[1,2,3,4]
    )



def main() -> None:
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    with open(args.input, "r") as f:
        content = f.read()

    EvalResult.init_bw_settings(set(args.bitwidth),set(),set())
    evalResult = parse_eval_result(content)
    assert len(evalResult[0].per_bit_res) == len(evalResult[1].per_bit_res)

    composite_distance_map:dict[int,float] = {}
    sequential_distance_map:dict[int,float] = {}
    for per_bit_result in evalResult[0].per_bit_res:
        composite_distance_map[per_bit_result.bitwidth] = per_bit_result.sound_dist
    for per_bit_result in evalResult[1].per_bit_res:
        assert per_bit_result.bitwidth in composite_distance_map
        sequential_distance_map[per_bit_result.bitwidth] = per_bit_result.sound_dist

    species = sorted(composite_distance_map)
    soundDistance:list[float] = [composite_distance_map[key] for key in species]
    benchmarkDistance:list[float] = [sequential_distance_map[key] for key in species]
    penguin_means = {
        'Composite': soundDistance,
        'Sequential': benchmarkDistance,
    }



    x = np.arange(len(species))  # the label locations
    width = 0.25  # the width of the bars
    multiplier = 0
    padding = 3

    fig, ax = plt.subplots(layout='constrained')

    for attribute, measurement in penguin_means.items():
        offset = width * multiplier
        rects = ax.bar(x + offset, measurement, width, label=attribute)
        ax.bar_label(rects, padding=padding)
        multiplier += 1
        padding+=10

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('The sum of different bits')
    ax.set_title('Bitwidth')
    ax.set_xticks(x + width, species)
    ax.legend(loc='upper left', ncols=3)
    #ax.set_ylim(0, 2000)

    plt.savefig(args.figure_path, dpi=300)




if __name__ == "__main__":
    main()
