from subprocess import run, PIPE
from enum import Enum
from tempfile import mkdtemp
from pathlib import Path
from typing import Callable, TypeVar

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitRes


class AbstractDomain(Enum):
    KnownBits = "KnownBits", 2
    UConstRange = "UConstRange", 2
    SConstRange = "SConstRange", 2
    IntegerModulo = "IntegerModulo", 6

    vec_size: int

    def __new__(
        cls,
        value: str,
        vec_size: int,
    ):
        obj = object.__new__(cls)
        obj._value_ = value
        obj.vec_size = vec_size
        return obj

    def __str__(self) -> str:
        return self.name


def _get_per_bit(x: list[str]) -> list[PerBitRes]:
    T = TypeVar("T")

    def get(in_str: str, to_match: str, parser: Callable[[str], T]) -> T:
        og_str, to_parse = in_str.split(":")

        assert og_str.strip() == to_match

        return parser(to_parse)

    def get_ints(s: str) -> list[int]:
        return eval(s)

    def get_floats(s: str) -> list[float]:
        return eval(s)

    bw = get(x[0], "bw", int)
    num_cases = get(x[1], "num cases", int)
    num_unsolved_cases = get(x[2], "num unsolved", int)
    base_distance = get(x[3], "base distance", float)
    sound = get(x[4], "num sound", get_ints)
    distance = get(x[5], "distance", get_floats)
    exact = get(x[6], "num exact", get_ints)
    num_unsolved_exact_cases = get(x[7], "num unsolved exact", get_ints)
    sound_distance = get(x[8], "sound distance", get_floats)

    assert len(sound) > 0, "No output from EvalEngine"
    assert (
        len(sound)
        == len(distance)
        == len(exact)
        == len(num_unsolved_exact_cases)
        == len(sound_distance)
    ), "EvalEngine output mismatch"

    return [
        PerBitRes(
            all_cases=num_cases,
            sounds=sound[i],
            exacts=exact[i],
            dist=distance[i],
            unsolved_cases=num_unsolved_cases,
            unsolved_exacts=num_unsolved_exact_cases[i],
            base_dist=base_distance,
            sound_dist=sound_distance[i],
            bitwidth=bw,
        )
        for i in range(len(sound))
    ]


def _parse_engine_output(output: str) -> list[EvalResult]:
    bw_evals = output.split("---\n")
    bw_evals.reverse()
    per_bits = [_get_per_bit(x.split("\n")) for x in bw_evals if x != ""]

    ds: list[list[PerBitRes]] = [[] for _ in range(len(per_bits[0]))]
    for es in per_bits:
        for i, e in enumerate(es):
            ds[i].append(e)

    return [EvalResult(x) for x in ds]


def setup_eval(
    domain: AbstractDomain,
    low_bws: list[int],
    med_bws: list[tuple[int, int]],
    high_bws: list[tuple[int, int, int]],
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
) -> list[EvalResult]:
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
) -> list[EvalResult]:
    engine_path = Path("xdsl_smt").joinpath("eval_engine", "build", "eval_engine")
    if not engine_path.exists():
        raise FileNotFoundError(f"Eval Engine not found at: {engine_path}")

    engine_params = ""
    engine_params += f"{data_dir}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{op_name}\n"
    engine_params += "\n"
    engine_params += f"{[xfer_name]}\n"
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
