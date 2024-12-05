import argparse
import subprocess

from xdsl.context import MLContext
from xdsl.parser import Parser

from io import StringIO

from xdsl.utils.hints import isa
from ..dialects.smt_dialect import (
    SMTDialect,
    DefineFunOp,
)
from ..dialects.smt_bitvector_dialect import (
    SMTBitVectorDialect,
    ConstantOp,
)
from xdsl_smt.dialects.transfer import (
    AbstractValueType,
    TransIntegerType,
    TupleType, GetOp,
)
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl.ir.core import BlockArgument, Attribute, BlockOps, Block
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
    IntegerAttr,
    IntegerType,
    i1,
    FunctionType,
    ArrayAttr,
    StringAttr,
    AnyArrayAttr,
)
from xdsl.dialects.func import Func, FuncOp, Return
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith
from ..passes.dead_code_elimination import DeadCodeElimination
from ..passes.merge_func_results import MergeFuncResultsPass
from ..passes.transfer_inline import FunctionCallInline
import xdsl.dialects.comb as comb
from xdsl.ir import Operation, SSAValue
from ..passes.lower_to_smt.lower_to_smt import LowerToSMTPass, SMTLowerer
from ..passes.lower_effects import LowerEffectPass
from ..passes.lower_to_smt import (
    func_to_smt_patterns,
)
from ..utils.transfer_function_util import (
    SMTTransferFunction,
    FunctionCollection,
    TransferFunction,
    fixDefiningOpReturnType,
)

from ..utils.transfer_function_check_util import (
    forward_soundness_check,
    backward_soundness_check,
    counterexample_check,
    int_attr_check,
)
from ..passes.transfer_unroll_loop import UnrollTransferLoop
from xdsl_smt.semantics import transfer_semantics
from ..traits.smt_printer import print_to_smtlib
from xdsl_smt.passes.lower_pairs import LowerPairs
from xdsl.transforms.canonicalize import CanonicalizePass
from xdsl_smt.semantics.arith_semantics import arith_semantics
from xdsl_smt.semantics.builtin_semantics import IntegerTypeSemantics
from xdsl_smt.semantics.transfer_semantics import (
    transfer_semantics,
    AbstractValueTypeSemantics,
    TransferIntegerTypeSemantics,
)
from xdsl_smt.semantics.comb_semantics import comb_semantics
import sys as sys


# This function iterates all functions inside the input module
def iterate_all_func(module: ModuleOp):
    for func in module.ops:
        if isinstance(func, FuncOp):
            print(func)


def iterate_func_arguments(func: FuncOp):
    for i, arg in enumerate(func.body.block.args):
        print(str(i) + "-th function arg is ", arg)


def iterate_operations(func: FuncOp):
    for i, op in enumerate(func.body.block.ops):
        print(str(i) + "-th operation is: ")
        print(op)


def set_ith_operand(op: Operation, ith: int, new_val: SSAValue):
    assert len(op.operands) > ith
    assert new_val.type == op.operands[ith].type
    op.operands[ith] = new_val


# Note: an MLIR operation can return multiple values, thus we need `ith` here
def get_ith_result(op: Operation, ith: int) -> SSAValue:
    assert len(op.results) > ith
    return op.results[ith]


import random


# Example: reset operands in all operations by random val
def example_reset_all_operands(func: FuncOp):
    dominated_vals: dict[Attribute, list[SSAValue]] = {}

    # Add function arguments
    for arg in func.body.block.args:
        if arg.type not in dominated_vals:
            dominated_vals[arg.type] = []
        dominated_vals[arg.type].append(arg)

    for op in func.body.block.ops:
        # Reset operands
        for i, operand in enumerate(op.operands):
            set_ith_operand(op, i, random.choice(dominated_vals[operand.type]))

        # Add results
        for res in op.results:
            if res.type not in dominated_vals:
                dominated_vals[res.type] = []
            dominated_vals[res.type].append(res)


from xdsl.dialects.arith import Constant, OrI, XOrI, AndI, Select


# Example: replace bitwise operation(AND/OR/XOR) randomly with another or select
def example_replace_bitwise_operation(func: FuncOp):
    true: Constant = Constant(IntegerAttr.from_int_and_width(1, 1), i1)
    false: Constant = Constant(IntegerAttr.from_int_and_width(0, 1), i1)

    # Add true and false to the front of function
    first_op: Operation = func.body.block.first_op
    func.body.block.insert_op_before(false, first_op)
    func.body.block.insert_op_before(true, first_op)

    candidates: list[int] = [0, 1, 2, 3]  # Select, And, Or, Xor
    old_ops: list[Operation] = []

    # Random update
    for op in func.body.block.ops:
        if isinstance(op, OrI) or isinstance(op, AndI) or isinstance(op, XOrI):
            choice = random.choice(candidates)
            if choice == 0:
                new_op = Select(random.choice([true, false]), op.operands[0], op.operands[1])
            elif choice == 1:
                new_op = AndI(op.operands[0], op.operands[1])
                pass
            elif choice == 2:
                new_op = OrI(op.operands[0], op.operands[1])
            else:
                new_op = XOrI(op.operands[0], op.operands[1])
            func.body.block.insert_op_before(new_op, op)
            op.results[0].replace_by(new_op.results[0])
            old_ops.append(op)

    # Remove old ops
    for op in old_ops:
        op.detach()


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

def get_init_program(func: FuncOp, len: int) -> FuncOp:

    block = func.body.block

    for op in block.ops:
        block.detach_op(op)

    return func


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

    # assert isinstance(module.ops.first, FuncOp)

    func = get_init_program(module.ops.first, 0)



    # todo: construct an empty program

    # for op in module.ops:
    #     if isinstance(op, FuncOp):
    #         example_replace_bitwise_operation(op)
    print(func)


if __name__ == "__main__":
    main()
