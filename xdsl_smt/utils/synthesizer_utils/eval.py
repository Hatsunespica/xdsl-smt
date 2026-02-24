import os.path
from subprocess import run, PIPE
from enum import Enum
from tempfile import mkdtemp
from pathlib import Path
from typing import Callable, TypeVar
from xdsl.context import Context
from functools import cached_property


from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitRes
from xdsl_smt.utils.synthesizer_utils.parse_result import parse_eval_result
from xdsl_smt.utils.synthesizer_utils.specification import Specification

from dataclasses import dataclass
from typing import Tuple, Sequence


@dataclass(init=False)
class EvalEngineParameter:
    eval_engine_path: str
    data_cache_path: str
    enumerate_bit_width: Tuple[int, ...]
    sample_bit_width: Tuple[int, ...]
    sample_concrete_amount: Tuple[int, ...]
    sample_abstract_amount: Tuple[int, ...]


    def __init__(
        self,
        eval_engine_path: str,
        data_cache_path: str,
        enumerate_bit_width: Sequence[int],
        sample_bit_width: Sequence[int],
        sample_concrete_amount: Sequence[int],
        sample_abstract_amount: Sequence[int],
    ):
        self.eval_engine_path = eval_engine_path
        self.data_cache_path = data_cache_path
        if not Path(eval_engine_path).is_file():
            raise FileNotFoundError(f"Eval Engine not found at: {eval_engine_path}")
        if not Path(data_cache_path).is_dir():
            raise FileNotFoundError(f"Data cache path not found at: {data_cache_path}")

        self.enumerate_bit_width = tuple(enumerate_bit_width)
        if any(bitwidth <= 0 for bitwidth in enumerate_bit_width) and len(enumerate_bit_width)!=0:
            raise FileNotFoundError(f"Incorrect bitwidth found: {enumerate_bit_width}")

        self.sample_bit_width = tuple(sample_bit_width)
        if any(bitwidth <= 0 for bitwidth in sample_bit_width):
            raise FileNotFoundError(f"Incorrect bitwidth found: {sample_bit_width}")

        self.sample_concrete_amount = tuple(sample_concrete_amount)
        if any(bitwidth <= 0 for bitwidth in sample_concrete_amount):
            raise FileNotFoundError(f"Incorrect bitwidth found: {sample_concrete_amount}")

        self.sample_abstract_amount = tuple(sample_abstract_amount)
        if any(bitwidth <= 0 for bitwidth in sample_abstract_amount):
            raise FileNotFoundError(f"Incorrect bitwidth found: {sample_abstract_amount}")


    @cached_property
    def cmd_list(self):
        return [
            self.eval_engine_path,
            "--stdin",
            f"--enumerate-bit-width={','.join(map(str, self.enumerate_bit_width))}",
            f"--sample-bit-width={','.join(map(str, self.sample_bit_width))}",
            f"--sample-concrete-amount={','.join(map(str, self.sample_concrete_amount))}",
            f"--sample-abstract-amount={','.join(map(str, self.sample_abstract_amount))}",
            f"--data-cache-path={self.data_cache_path}",
            "--jit-config=-S",
            "--max-operation-length=32",
        ]



def eval_transfer_func(
    transfer_names: list[str],
    transfer_srcs: list[str],
    base_names: list[str],
    base_srcs: list[str],
    spec: Specification,
    eval_parameters:EvalEngineParameter,
    context: Context,
) -> list[EvalResult]:
    source_code = spec.lower_to_cpp(context) + "\n".join(transfer_srcs+base_srcs)

    params = {
        "--domain": spec.domain_name,
        "--transfer-function": ",".join(transfer_names),
        "--base-transfer-function": ",".join(base_names),
        "--abstract-domain-length": spec.abstract_domain_length,
        "--transfer-function-arity": spec.transfer_function_arity,
    }

    cmd = eval_parameters.cmd_list

    for key, value in params.items():
        cmd.append(f"{key}={value}")

    eval_output = run(
        cmd,
        input=source_code,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    return parse_eval_result(eval_output.stdout)


def eval_final(
    final_name: str,
    final_str: str,
    transfer_srcs: list[str],
    spec: Specification,
    eval_parameters: EvalEngineParameter,
    context: Context,
) -> list[EvalResult]:
    source_code = spec.lower_to_cpp(context) + "\n".join(transfer_srcs+[final_str])

    params = {
        "--domain": spec.domain_name,
        "--transfer-function": final_name,
        "--abstract-domain-length": spec.abstract_domain_length,
        "--transfer-function-arity": spec.transfer_function_arity,
    }

    cmd = eval_parameters.cmd_list

    for key, value in params.items():
        cmd.append(f"{key}={value}")

    eval_output = run(
        cmd,
        input=source_code,
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    return parse_eval_result(eval_output.stdout)

