from subprocess import run, PIPE
from enum import Enum
from tempfile import mkdtemp
from typing import Callable
from pathlib import Path

from xdsl_smt.utils.synthesizer_utils.compare_result import (
    EvalResult,
    HighBitRes,
    HighPerBitRes,
    LowPerBitRes,
)


class AbstractDomain(Enum):
    KnownBits = ("KnownBits", 2, lambda x: x * 2, lambda x: x)  # type: ignore
    UConstRange = ("UConstRange", 2, lambda x: 2**x - 1)  # type: ignore
    SConstRange = ("SConstRange", 2, lambda x: 2**x - 1)  # type: ignore
    IntegerModulo = ("IntegerModulo", 6, lambda _: 12, lambda _: 6)  # type: ignore

    vec_size: int
    max_dist: Callable[[int], int]
    max_size: Callable[[int], int]

    def __new__(
        cls,
        value: str,
        vec_size: int,
        max_dist: Callable[[int], int],
        max_size: Callable[[int], int],
    ):
        obj = object.__new__(cls)
        obj._value_ = value
        obj.vec_size = vec_size
        obj.max_dist = max_dist
        obj.max_size = max_size
        return obj

    def __str__(self) -> str:
        return self.name


def _get_per_bit(x: list[str]) -> list[LowPerBitRes]:
    def get_floats(s: str) -> list[int]:
        return eval(s)

    bw = int(x[0][4:])
    sounds = get_floats(x[2])
    precs = get_floats(x[4])
    exact = get_floats(x[6])
    num_cases = get_floats(x[8])
    unsolved_sounds = get_floats(x[10])
    unsolved_precs = get_floats(x[12])
    unsolved_exact = get_floats(x[14])
    unsolved_num_cases = get_floats(x[16])
    base_precs = get_floats(x[18])
    sound_distance = get_floats(x[20])

    assert len(sounds) > 0, "No output from EvalEngine"
    assert (
        len(sounds)
        == len(precs)
        == len(exact)
        == len(num_cases)
        == len(unsolved_sounds)
        == len(unsolved_precs)
        == len(unsolved_exact)
        == len(unsolved_num_cases)
        == len(base_precs)
        == len(sound_distance)
    ), "EvalEngine output mismatch"

    return [
        LowPerBitRes(
            all_cases=num_cases[i],
            sounds=sounds[i],
            exacts=exact[i],
            dist=precs[i],
            unsolved_cases=unsolved_num_cases[i],
            unsolved_sounds=unsolved_sounds[i],
            unsolved_exacts=unsolved_exact[i],
            unsolved_dist=unsolved_precs[i],
            base_dist=base_precs[i],
            sound_dist=sound_distance[i],
            bitwidth=bw,
        )
        for i in range(len(sounds))
    ]


def _get_per_bit_high(x: list[str]) -> list[HighPerBitRes]:
    def get_floats(s: str) -> list[int]:
        return eval(s)

    bw = int(x[0][4:])
    ref_score = int(x[1][11:])
    num_samples = int(x[2][13:])
    synth_score_sums = get_floats(x[4])
    meet_score_sums = get_floats(x[6])
    num_bottoms = get_floats(x[8])

    assert (
        len(synth_score_sums) == len(meet_score_sums) == len(num_bottoms)
    ), "EvalEngine output mismatch"

    return [
        HighPerBitRes(
            synth_score_sum=ss,
            meet_score_sum=ms,
            num_bottoms=nb,
            num_samples=num_samples,
            ref_score=ref_score,
            bitwidth=bw,
        )
        for ss, ms, nb in zip(synth_score_sums, meet_score_sums, num_bottoms)
    ]


def _parse_engine_output(output: str) -> list[tuple[EvalResult, HighBitRes]]:
    low_and_med, high_bw_output = output.split("high bws:\n")
    low_and_med = low_and_med.replace("low bws:\n", "")
    low_bw_out, med_bw_out = low_and_med.split("med bws:\n")

    low_and_med_res = _parse_low_bw(med_bw_out + low_bw_out)
    high_res = _parse_high_bw(high_bw_output)

    print(list(zip(low_and_med_res, high_res)))

    return list(zip(low_and_med_res, high_res))


def _parse_low_bw(output: str) -> list[EvalResult]:
    bw_evals = output.split("---\n")
    bw_evals.reverse()
    per_bits = [_get_per_bit(x.split("\n")) for x in bw_evals if x != ""]

    ds: list[list[LowPerBitRes]] = [[] for _ in range(len(per_bits[0]))]
    for es in per_bits:
        for i, e in enumerate(es):
            ds[i].append(e)

    return [EvalResult(x) for x in ds]


def _parse_high_bw(output: str) -> list[HighBitRes]:
    bw_evals = output.split("---\n")
    bw_evals.reverse()

    per_bits = [_get_per_bit_high(x.split("\n")) for x in bw_evals if x != ""]

    ds: list[list[HighPerBitRes]] = [[] for _ in range(len(per_bits[0]))]
    for es in per_bits:
        for i, e in enumerate(es):
            ds[i].append(e)

    return [HighBitRes(x) for x in ds]


def setup_eval(
    domain: AbstractDomain,
    low_bws: list[int],
    med_bws: list[tuple[int, int]],
    high_bws: list[tuple[int, int]],
    seed: int,
    conc_op_src: str,
) -> str:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "xfer_enum")
    if not engine_path.exists():
        raise FileNotFoundError(f"Enumeration Engine not found at: {engine_path}")

    dirpath = f"{mkdtemp()}/"

    engine_params = ""
    engine_params += f"{dirpath}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{low_bws}\n"
    engine_params += f"{med_bws}\n"
    engine_params += f"{high_bws}\n"
    engine_params += f"{seed}\n"
    engine_params += "using A::APInt;\n"
    engine_params += f"{conc_op_src}"

    engine_output = run(
        [engine_path],
        input=engine_params,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if engine_output.returncode != 0:
        print("Enumeration Engine failed with this error:")
        print(engine_output.stderr, end="")
        exit(engine_output.returncode)

    return dirpath


def reject_sampler(
    domain: AbstractDomain,
    data_dir: str,
    samples: int,
    seed: int,
    conc_op_and_helpers: list[str],
    base_names: list[str],
    base_srcs: list[str],
) -> None:
    print("reject sampler not impl'd yet")
    print(domain, data_dir, samples, seed, conc_op_and_helpers, base_names, base_srcs)
    exit(1)


def eval_transfer_func(
    data_dir: str,
    xfer_names: list[str],
    xfer_srcs: list[str],
    base_names: list[str],
    base_srcs: list[str],
    helper_srcs: list[str],
    domain: AbstractDomain,
) -> list[tuple[EvalResult, HighBitRes]]:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "eval_engine")
    if not engine_path.exists():
        raise FileNotFoundError(f"Eval Engine not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += "\n"
    engine_params += f"{xfer_names}\n"
    engine_params += f"{base_names}\n"
    engine_params += "using A::APInt;\n"
    engine_params += "\n".join(helper_srcs + xfer_srcs + base_srcs)

    eval_output = run(
        [engine_path],
        input=engine_params,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    return _parse_engine_output(eval_output.stdout)


def eval_final(
    data_dir: str,
    xfer_name: str,
    xfer_src: str,
    op_name: str,
    helper_srcs: list[str],
    domain: AbstractDomain,
) -> list[tuple[EvalResult, HighBitRes]]:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "eval_engine")
    if not engine_path.exists():
        raise FileNotFoundError(f"Eval Engine not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{op_name}\n"
    engine_params += "\n"
    engine_params += f"{xfer_name}\n"
    engine_params += "using A::APInt;\n"
    engine_params += "\n".join(helper_srcs + [xfer_src])

    eval_output = run(
        [engine_path],
        input=engine_params,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    return _parse_engine_output(eval_output.stdout)
