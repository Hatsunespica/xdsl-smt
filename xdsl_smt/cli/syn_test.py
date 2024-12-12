import argparse
import subprocess

from xdsl.context import MLContext
from xdsl.parser import Parser

from io import StringIO

from xdsl.utils.hints import isa

from xdsl_smt.dialects import transfer
from xdsl.dialects import arith
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
    TupleType, GetOp, SelectOp, AndOp, OrOp, XorOp, CmpOp,
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
    AnyArrayAttr, IndexType,
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
    TransferIntegerTypeSemantics, CmpOpSemantics,
)
from xdsl_smt.semantics.comb_semantics import comb_semantics
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


def get_valid_bool_operands(ops: [Operation], x: int) -> ([Operation], int):
    """
    Get operations that before ops[x] so that can serve as operands
    """
    bool_ops = [op for op in ops[:x] if len(op.results) > 0 and op.results[0].type == i1]
    bool_count = len(bool_ops)
    assert bool_count > 0
    return bool_ops, bool_count


def get_valid_int_operands(ops: [Operation], x: int) -> ([Operation], int):
    """
    Get operations that before ops[x] so that can serve as operands
    """
    int_ops = [op for op in ops[:x] if len(op.results) > 0 and isinstance(op.results[0].type, TransIntegerType)]
    int_count = len(int_ops)
    assert int_count > 0
    return int_ops, int_count


def replace_entire_operation(ops: [Operation], modifiable_indices: [int]) -> (Operation, Operation, float):
    """
    Random pick an operation and replace it with a new one
    """
    idx = random.choice(modifiable_indices)
    old_op = ops[idx]
    new_op = None

    (int_operands, num_int_operands) = get_valid_int_operands(ops, idx)
    (bool_operands, num_bool_operands) = get_valid_bool_operands(ops, idx)

    def calculate_operand_prob(op: Operation) -> int:
        # todo: fix it
        ret = 1
        for operand in op.operands:
            if operand.type == IntegerType(4):
                ret = ret * num_int_operands
            elif operand.type == i1:
                ret = ret * num_bool_operands
        return ret

    if old_op.results[0].type == i1:  # bool
        candidate = [arith.AndI.name, arith.OrI.name, CmpOp.name]
        if old_op.name in candidate:
            candidate.remove(old_op.name)
        opcode = random.choice(candidate)
        op1 = random.choice(bool_operands)
        op2 = random.choice(bool_operands)
        if opcode == arith.AndI.name:
            new_op = arith.AndI(op1, op2)
        elif opcode == arith.OrI.name:
            new_op = arith.OrI(op1, op2)
        elif opcode == CmpOp.name:
            predicate = random.randrange(len(CmpOpSemantics.new_ops))
            int_op1 = random.choice(int_operands)
            int_op2 = random.choice(int_operands)
            new_op = CmpOp(operands=[int_op1, int_op2], attributes={"predicate": IntegerAttr(predicate, IndexType())},
                           result_types=[i1])

        forward_prob = calculate_operand_prob(old_op)
        backward_prob = calculate_operand_prob(new_op)

    else:  # integer
        assert isinstance(old_op.results[0].type, TransIntegerType)
        candidate = [AndOp.name, OrOp.name, XorOp.name, SelectOp.name]
        if old_op.name in candidate:
            candidate.remove(old_op.name)
        opcode = random.choice(candidate)
        op1 = random.choice(int_operands)
        op2 = random.choice(int_operands)
        if opcode == AndOp.name:
            new_op = AndOp(operands=[op1, op2], result_types=[op1.results[0].type])
        elif opcode == OrOp.name:
            new_op = OrOp(operands=[op1, op2], result_types=[op1.results[0].type])
        elif opcode == XorOp.name:
            new_op = XorOp(operands=[op1, op2], result_types=[op1.results[0].type])
        else:
            cond = random.choice(bool_operands)
            new_op = SelectOp(operands=[cond, op1, op2], result_types=[op1.results[0].type])

        forward_prob = calculate_operand_prob(old_op)
        backward_prob = calculate_operand_prob(new_op)

    return old_op, new_op, forward_prob / backward_prob


def replace_operand(ops: [Operation], modifiable_indices: [int]) -> float:
    idx = random.choice(modifiable_indices)
    op = ops[idx]
    (int_operands, num_int_operands) = get_valid_int_operands(ops, idx)
    (bool_operands, num_bool_operands) = get_valid_bool_operands(ops, idx)

    ith = random.randrange(len(op.operands))
    if op.operands[ith].type == i1:
        op.operands[ith] = random.choice(bool_operands)
    elif isinstance(op.results[0].type, TransIntegerType):
        # op.operands[ith] = random.choice(int_operands)
        pass
    pass


def sample_next(func: FuncOp) -> (FuncOp, float):
    """
    Sample the next program.
    Return the new program with the proposal ratio.
    """
    ops = list(func.body.block.ops)

    while 1:
        sample_model = random.randrange(4)
        if sample_model == 0:
            modifiable_ops = range(6, len(ops))
            old_op, new_op, ratio = replace_entire_operation(ops, modifiable_ops)
            # print(f"old: {old_op}\n new: {new_op} \n ratio: {ratio}")
            func.body.block.insert_op_before(new_op, old_op)
            if len(old_op.results) > 0 and len(new_op.results) > 0:
                old_op.results[0].replace_by(new_op.results[0])
            func.body.block.detach_op(old_op)


        else:
            modifiable_ops = [i for i, op in enumerate(ops[6:], start=6) if bool(op.operands)]
            if not modifiable_ops:
                continue
            else:
                ratio = 1
                # todo: fix the following function
                # ratio = replace_operand(ops, modifiable_ops)
        break

    return func, ratio


def get_init_program(func: FuncOp, len: int) -> FuncOp:
    block = func.body.block

    for op in block.ops:
        block.detach_op(op)

    true: arith.Constant = arith.Constant(IntegerAttr.from_int_and_width(1, 1), i1)
    false: arith.Constant = arith.Constant(IntegerAttr.from_int_and_width(0, 1), i1)
    # zero: Constant = Constant(IntegerAttr.from_int_and_width(0, 4), IntegerType(4))
    # one: Constant = Constant(IntegerAttr.from_int_and_width(1, 4), IntegerType(4))
    block.add_op(true)
    block.add_op(false)
    # block.add_op(zero)
    # block.add_op(one)

    for arg in func.body.block.args:
        if isinstance(arg.type, AbstractValueType):
            for i, field_type in enumerate(arg.type.get_fields()):
                op = GetOp(operands=[arg], attributes={"index": IntegerAttr(i, IndexType())}, result_types=[field_type])
                block.add_op(op)

    tmp_int_op = block.last_op.results[0]
    for i in range(len // 2):
        nop_bool = arith.Constant(IntegerAttr.from_int_and_width(1, 1), i1)
        nop_int = transfer.Constant(tmp_int_op, 0)
        block.add_op(nop_bool)
        block.add_op(nop_int)

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
    assert isinstance(module.ops.first, FuncOp)

    print(module)

    func = get_init_program(module.ops.first, 8)
    for i in range(10):
        func, _ = sample_next(func)

    print(module)


if __name__ == "__main__":
    main()
