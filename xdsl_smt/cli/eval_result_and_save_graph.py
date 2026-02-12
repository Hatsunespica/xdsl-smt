#!/usr/bin/env python3

import argparse

from xdsl_smt.utils.synthesizer_utils.compare_result import PerBitRes, EvalResult
import matplotlib.pyplot as plt
import numpy as np

def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "input", type=str, help="input to the specification file"
    )
    arg_parser.add_argument(
        "figure_path", nargs='?', type=str, help="Saved figure path", default="result.png"
    )


RESULT_DELIMITER="======="
PER_BIT_RESULT_DELIMITER="------"

def parse_per_bit_result(text: str) -> list[PerBitRes]:
    lines = [line.strip() for line in text.splitlines() if line.strip()]

    # ---- shared header ----
    bitwidth = int(lines[0].split(": ")[1])
    total_cases = int(lines[1].split(": ")[1])
    total_unsolved = int(lines[2].split(": ")[1])
    base_dist = int(lines[3].split(": ")[1])  # still int in output

    results: list[PerBitRes] = []
    current = {}

    for line in lines[4:]:
        if line == "------":
            if current:
                results.append(
                    PerBitRes(
                        all_cases=total_cases,
                        bitwidth=bitwidth,
                        sounds=current["soundCases"],
                        exacts=current["exactCases"],
                        dist=current["distance"],              # int assigned to float field
                        base_dist=base_dist,                   # int assigned to float field
                        unsolved_cases=total_unsolved,
                        unsolved_exacts=current["unsolvedExactCases"],
                        sound_dist=current["soundDistance"],   # int assigned to float field
                    )
                )
                current = {}
            continue

        key, value = line.split(" = ")
        current[key] = int(value)

    return results

def parse_eval_result(full_text:str)->list[EvalResult]:
    """
    Top-level parser.

    - Find the first occurrence of the literal line 'print result'
    - Take everything after that line
    - Split by the exact separator '=======' (7 equals)
    - Call parse_per_bit_result on each chunk and keep only non-empty parsed Results
    - Ignore empty/parsing-failed chunks (this drops trailing metadata or stray text)
    """
    sentinel = "print result"
    idx = full_text.find(sentinel)
    if idx == -1:
        return []

    # Start just after the sentinel line
    start = idx + len(sentinel)

    region = full_text[start:].strip()

    parts = [part.strip() for part in region.split("=======")]
    parts.pop(-1)

    result: list[EvalResult] = []
    for part in parts:
        if not part:
            continue
        per_bit_result_list = parse_per_bit_result(part)
        if per_bit_result_list:               # only keep non-empty parsed results
            result.append(EvalResult(per_bit_result_list))
        # else: skip chunk silently (this ignores trailing metadata or malformed chunks)

    return result


def main() -> None:
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    with open(args.input, "r") as f:
        content = f.read()

    EvalResult.init_bw_settings({1,2,3,4},set(),set())
    evalResult = parse_eval_result(content)
    soundDistance:list[float] = []
    benchmarkDistance:list[float] = []
    for result in evalResult:
        per_bit_result = result.per_bit_res
        soundDistance.append(per_bit_result[0].sound_dist)
        benchmarkDistance.append(per_bit_result[1].sound_dist)
    #species = ("1", "2", "3", "4")
    penguin_means = {
        'Composite': soundDistance,
        'Sequential': benchmarkDistance,
    }
    species = [str(i) for i in range(len(soundDistance))]

    x = np.arange(len(species))  # the label locations
    width = 0.25  # the width of the bars
    multiplier = 0

    fig, ax = plt.subplots(layout='constrained')

    for attribute, measurement in penguin_means.items():
        offset = width * multiplier
        rects = ax.bar(x + offset, measurement, width, label=attribute)
        ax.bar_label(rects, padding=3)
        multiplier += 1

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('The sum of different bits')
    ax.set_title('Bitwidth')
    ax.set_xticks(x + width, species)
    ax.legend(loc='upper left', ncols=3)
    #ax.set_ylim(0, 2000)

    plt.savefig(args.figure_path)




if __name__ == "__main__":
    main()
