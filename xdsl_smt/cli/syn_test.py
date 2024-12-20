import argparse

from xdsl.context import MLContext
from xdsl.parser import Parser

from xdsl_smt.utils.mcmc_sampler import MCMCSampler
from ..dialects.smt_dialect import (
    SMTDialect,
)
from ..dialects.smt_bitvector_dialect import (
    SMTBitVectorDialect,
)
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
)
from xdsl.dialects.func import Func, FuncOp
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith
from xdsl.ir import Operation
import sys as sys
import random


def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "transfer_functions", type=str, nargs="?", help="path to the transfer functions"
    )


def parse_file(ctx: MLContext, file: str | None) -> Operation:
    if file is None:
        f = sys.stdin
        file = "<stdin>"
    else:
        f = open(file)

    parser = Parser(ctx, f.read(), file)
    module = parser.parse_op()
    return module


def main() -> None:
    global ctx
    ctx = MLContext()
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    # Register all dialects
    ctx.load_dialect(Arith)
    ctx.load_dialect(Builtin)
    ctx.load_dialect(Func)
    ctx.load_dialect(SMTDialect)
    ctx.load_dialect(SMTBitVectorDialect)
    ctx.load_dialect(SMTUtilsDialect)
    ctx.load_dialect(Transfer)
    ctx.load_dialect(Index)

    # Parse the files
    module = parse_file(ctx, args.transfer_functions)
    assert isinstance(module, ModuleOp)
    assert isinstance(module.ops.first, FuncOp)

    random.seed(47)
    func = module.ops.first

    mcmcSampler = MCMCSampler(func, 8)

    for i in range(100):
        print(f"Round {i}:{mcmcSampler.func}")
        _: float = mcmcSampler.sample_next()

    print(mcmcSampler.func)


if __name__ == "__main__":
    main()
