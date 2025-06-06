from subprocess import run, PIPE
from enum import Enum
from tempfile import mkdtemp
from typing import Callable
from pathlib import Path

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitEvalResult


class AbstractDomain(Enum):
    KnownBits = ("KnownBits", 2, lambda x: x * 2)  # type: ignore
    UConstRange = ("UConstRange", 2, lambda x: (2**x - 1) * 2)  # type: ignore
    SConstRange = ("SConstRange", 2, lambda x: (2**x - 1) * 2)  # type: ignore
    IntegerModulo = ("IntegerModulo", 6, lambda _: 12)  # type: ignore

    vec_size: int
    max_dist: Callable[[int], int]

    def __new__(cls, value: str, vec_size: int, max_dist: Callable[[int], int]):
        obj = object.__new__(cls)
        obj._value_ = value
        obj.vec_size = vec_size
        obj.max_dist = max_dist
        return obj

    def __str__(self) -> str:
        return self.name


def _get_per_bit(x: list[str]) -> list[PerBitEvalResult]:
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
        PerBitEvalResult(
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


def _parse_engine_output(output: str) -> list[EvalResult]:
    bw_evals = output.split("---\n")
    bw_evals.reverse()
    per_bits = [_get_per_bit(x.split("\n")) for x in bw_evals if x != ""]

    ds: list[list[PerBitEvalResult]] = [[] for _ in range(len(per_bits[0]))]
    for es in per_bits:
        for i, e in enumerate(es):
            ds[i].append(e)

    return [EvalResult(x) for x in ds]


def setup_eval(
    domain: AbstractDomain,
    max_bitwidth: int,
    min_bitwidth: int,
    samples: tuple[int, int] | None,
    conc_op_src: str,
) -> str:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "xfer_enum")
    if not engine_path.exists():
        raise FileNotFoundError(f"Enumeration Engine not found at: {engine_path}")

    dirpath = f"{mkdtemp()}/"

    engine_params = ""
    engine_params += f"{dirpath}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{max_bitwidth}\n"
    engine_params += f"{min_bitwidth}\n"
    engine_params += f"{samples[0]} {samples[1]}\n" if samples is not None else "\n"
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


def eval_llvm(
    domain: AbstractDomain, data_dir: str, op_name: str
) -> tuple[EvalResult, EvalResult]:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "llvm_eval")
    if not engine_path.exists():
        raise FileNotFoundError(f"LLVM Eval not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{op_name}\n"

    eval_output = run(
        [engine_path],
        input=engine_params,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("LLVM Eval Engine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    results = _parse_engine_output(eval_output.stdout)
    assert len(results) == 2

    return results[0], results[1]


def reject_sampler(
    domain: AbstractDomain,
    data_dir: str,
    samples: int,
    seed: int,
    conc_op_and_helpers: list[str],
    base_names: list[str],
    base_srcs: list[str],
):
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "reject_sampling")
    if not engine_path.exists():
        raise FileNotFoundError(f"Reject Sampler not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{samples}\n"
    engine_params += f"{seed}\n"
    engine_params += f"{' '.join(base_names)}\n"
    engine_params += "using A::APInt;\n"
    engine_params += "\n".join(conc_op_and_helpers)
    engine_params += "\n".join(base_srcs)

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


def eval_transfer_func(
    data_dir: str,
    xfer_names: list[str],
    xfer_srcs: list[str],
    base_names: list[str],
    base_srcs: list[str],
    helper_srcs: list[str],
    domain: AbstractDomain,
) -> list[EvalResult]:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "eval_engine")
    if not engine_path.exists():
        raise FileNotFoundError(f"Eval Engine not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{' '.join(xfer_names)}\n"
    engine_params += f"{' '.join(base_names)}\n"
    engine_params += "using A::APInt;\n"

    all_src = "\n".join(helper_srcs + xfer_srcs + base_srcs)
    engine_params += all_src

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
