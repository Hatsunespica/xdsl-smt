from os import path
from subprocess import run, PIPE
from enum import Enum, auto
from tempfile import mkdtemp

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitEvalResult


class AbstractDomain(Enum):
    KnownBits = auto()
    ConstantRange = auto()
    IntegerModulo = auto()

    def __str__(self) -> str:
        return self.name


def setup_eval(
    domain: AbstractDomain,
    min_bitwidth: int,
    bitwidth: int,
    samples: tuple[int, int] | None,
    conc_op_src: str,
) -> str:
    base_dir = path.join("xdsl_smt", "eval_engine")
    engine_path = path.join(base_dir, "build", "xfer_enum")
    if not path.exists(engine_path):
        raise FileExistsError(f"Enumeration Engine not found at: {engine_path}")

    dirpath = f"{mkdtemp()}/"

    engine_params = ""
    engine_params += f"{dirpath}\n"
    engine_params += f"{domain}\n"
    engine_params += f"{min_bitwidth}\n"
    engine_params += f"{bitwidth}\n"
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


def reject_sampler(
    domain: AbstractDomain,
    data_dir: str,
    samples: int,
    seed: int,
    conc_op_and_helpers: list[str],
    base_names: list[str],
    base_srcs: list[str],
):
    base_dir = path.join("xdsl_smt", "eval_engine")
    engine_path = path.join(base_dir, "build", "reject_sampling")
    if not path.exists(engine_path):
        raise FileExistsError(f"Reject Sampler not found at: {engine_path}")

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
    base_dir = path.join("xdsl_smt", "eval_engine")
    engine_path = path.join(base_dir, "build", "eval_engine")
    if not path.exists(engine_path):
        raise FileExistsError(f"Eval Engine not found at: {engine_path}")

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

    def get_floats(s: str) -> list[int]:
        return eval(s)

    def get_per_bit(x: list[str]) -> tuple[int, list[PerBitEvalResult]]:
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

        assert len(sounds) > 0, f"No output from EvalEngine: {eval_output}"
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
        ), f"EvalEngine output mismatch: {eval_output}"

        return bw, [
            PerBitEvalResult(
                num_cases[i],
                sounds[i],
                exact[i],
                precs[i],
                unsolved_num_cases[i],
                unsolved_sounds[i],
                unsolved_exact[i],
                unsolved_precs[i],
                base_precs[i],
                sound_distance[i],
                bw,
            )
            for i in range(len(sounds))
        ]

    bw_evals = eval_output.stdout.split("---\n")
    bw_evals.reverse()
    per_bits = [get_per_bit(x.split("\n")) for x in bw_evals if x != ""]

    ds: list[dict[int, PerBitEvalResult]] = [{} for _ in range(len(per_bits[0][1]))]
    for bw, es in per_bits:
        for i, e in enumerate(es):
            ds[i][bw] = e

    return [EvalResult(x) for x in ds]
