import logging
from typing import cast, List
from io import StringIO
from pathlib import Path

from xdsl.context import Context
from xdsl.parser import Parser

from xdsl_smt.passes.transfer_inline import FunctionCallInline
from ..dialects.smt_dialect import SMTDialect
from ..dialects.smt_bitvector_dialect import SMTBitVectorDialect
from xdsl_smt.dialects.transfer import AbstractValueType
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl_smt.eval_engine.eval import (
    AbstractDomain,
)
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
    FunctionType,
)
from xdsl.dialects.func import Func, FuncOp
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith
from xdsl.dialects.comb import Comb
from xdsl.dialects.hw import HW
from ..passes.transfer_dead_code_elimination import TransferDeadCodeElimination


from ..passes.transfer_lower import LowerToCpp


from xdsl_smt.utils.synthesizer_utils.log_utils import (
    setup_loggers,
)
from xdsl_smt.cli.arg_parser import register_arguments


def create_context() -> Context:
    """Create and configure a context with all required dialects."""
    ctx = Context()
    ctx.load_dialect(Arith)
    ctx.load_dialect(Builtin)
    ctx.load_dialect(Func)
    ctx.load_dialect(SMTDialect)
    ctx.load_dialect(SMTBitVectorDialect)
    ctx.load_dialect(SMTUtilsDialect)
    ctx.load_dialect(Transfer)
    ctx.load_dialect(Index)
    ctx.load_dialect(Comb)
    ctx.load_dialect(HW)
    return ctx


def parse_file(ctx: Context, file: Path) -> ModuleOp:
    with open(file, "r") as f:
        module = Parser(ctx, f.read(), file.name).parse_op()

    assert isinstance(module, ModuleOp)

    return module


def eliminate_dead_code(ctx: Context, func: FuncOp) -> FuncOp:
    """
    WARNING: this function modifies the func passed to it in place!
    """
    TransferDeadCodeElimination().apply(ctx, cast(ModuleOp, func))
    return func


def eliminate_dead_code_not_in_place(ctx: Context, func: FuncOp) -> FuncOp:
    """
    This function eliminates dead code
    and it makes a copy of the function so it does not modify in place
    """
    region = func.body.clone()
    cloned_func = FuncOp(func.sym_name.data, func.function_type, region=region)
    TransferDeadCodeElimination().apply(ctx, cast(ModuleOp, cloned_func))
    return cloned_func


def print_to_cpp(ctx: Context, func: FuncOp) -> str:
    """
    This function eliminates dead code before lowering to cpp
    and it makes a copy of the function so it does not modify in place
    """
    sio = StringIO()
    region = func.body.clone()
    cloned_func = FuncOp(func.sym_name.data, func.function_type, region=region)
    TransferDeadCodeElimination().apply(ctx, cast(ModuleOp, cloned_func))
    LowerToCpp(sio).apply(ctx, cast(ModuleOp, cloned_func))

    return sio.getvalue()


def is_transfer_function(func: FuncOp) -> bool:
    return "applied_to" in func.attributes


def convert_xfer_func(fn: FuncOp, ty: AbstractValueType):
    "Warning: this modifies the `FuncOp` in place"
    fn.function_type = FunctionType.from_lists([ty, ty], [ty])
    fn.body.block.insert_arg(ty, 0)
    fn.body.block.insert_arg(ty, 0)

    *_, op = fn.body.block.ops
    op.operands[-1].replace_by(fn.body.block.args[0])

    fn.body.block.erase_arg(fn.body.block.args[2])
    fn.body.block.erase_arg(fn.body.block.args[2])


def get_helper_funcs(ctx: Context, p: Path) -> tuple[ModuleOp, List[FuncOp]]:
    with open(p, "r") as f:
        module = Parser(ctx, f.read(), p.name).parse_op()
        assert isinstance(module, ModuleOp)

    fns = {x.sym_name.data: x for x in module.ops if isinstance(x, FuncOp)}
    # FunctionCallInline(False, fns).apply(ctx, module)

    x = [x for x in fns.values() if is_transfer_function(x)]
    assert len(x) != 0, "No transfer function is found in input file"
    xfer_funcs = x

    # ty = AbstractValueType([TransIntegerType() for _ in range(d.vec_size)])
    # convert_xfer_func(transfer_func, ty)

    return module, xfer_funcs


def run(
    transfer_functions: Path,
):
    ctx = create_context()
    module, xfer_funcs = get_helper_funcs(ctx, transfer_functions)

    # Import the rewriter module
    from xdsl_smt.egraph_rewriter.rewriter import rewrite_transfer_functions

    # Rewrite the transfer functions
    rewritten_funcs = rewrite_transfer_functions(xfer_funcs)

    print(f"Successfully processed {len(rewritten_funcs)} transfer functions")


def main() -> None:
    args = register_arguments("egraph_rewriter")

    run(transfer_functions=args.transfer_functions)


if __name__ == "__main__":
    main()
