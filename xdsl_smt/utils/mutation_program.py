import argparse

from xdsl.context import MLContext
from xdsl.parser import Parser

from xdsl.utils.exceptions import VerifyException
from xdsl_smt.dialects import transfer
from xdsl_smt.utils.compare_result import CompareResult
from xdsl_smt.utils.synth_operators import SyZero, SyOne, SyAllOnes, SyBitWidth, SyFalse, SyTrue, SyCountLZero, SyAndI, SyAnd, \
    SynthOperator, SynthType
from xdsl_smt.utils.synthesizer_context import SynthesizerContext
from xdsl_smt.utils.random import Random
from xdsl.dialects import arith
from xdsl.dialects.builtin import (
    IntegerAttr,
    IntegerType,
    i1,
)
from xdsl.dialects.func import FuncOp, Return
from xdsl.ir import Operation, OpResult, SSAValue, Block
import sys as sys

from xdsl_smt.dialects.transfer import (
    AbstractValueType,
    TransIntegerType,
    GetOp,
    MakeOp,
    GetAllOnesOp,
    Constant,
)



class MutationProgram:

    func: FuncOp
    ops: list[Operation]
    # Maintain the consistency between ops and func manually

    def __init__(self, func: FuncOp, ops: list[Operation] | None = None):
        if ops is None:
            ops = list(func.body.block.ops)
        self.func = func
        self.ops = ops

    def clone(self):
        new_func = self.func.clone()
        new_ops = list(new_func.body.block.ops)
        return MutationProgram(new_func, new_ops)



    def get_modifiable_operations(self, only_live:bool = True) -> list[tuple[Operation, int]]:
        assert isinstance(self.ops[-1], Return)
        assert isinstance(self.ops[-2], MakeOp)
        last_make_op = self.ops[-2]

        live_set = set[Operation]()
        modifiable_ops = list[tuple[Operation, int]]()

        for operand in last_make_op.operands:
            assert isinstance(operand.owner, Operation)
            live_set.add(operand.owner)


        for idx in range(len(self.ops) - 3, -1, -1):
            operation = self.ops[idx]
            if not isinstance(operation, SynthOperator):
                continue
            if only_live:
                if operation in live_set:
                    modifiable_ops.append((operation, idx))
                    for operand in operation.operands:
                        assert isinstance(operand.owner, Operation)
                        live_set.add(operand.owner)
            else:
                modifiable_ops.append((operation, idx))

        return modifiable_ops

    def replace_operation(self, old_op, new_op):
        block = self.func.body.block
        block.insert_op_before(new_op, old_op)
        if len(old_op.results) > 0 and len(new_op.results) > 0:
            old_op.results[0].replace_by(new_op.results[0])
        block.detach_op(old_op)
        self.ops = list(block.ops)

    def get_valid_bool_operands(self, x: int) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        bool_ops: list[SSAValue] = [
            op.results[0] for op in self.ops[:x]
            if (isinstance(op, SynthOperator) and op.res_type == SynthType.BOOL)
            or isinstance(op, (SyTrue, SyFalse))
        ]
        bool_count = len(bool_ops)
        return bool_ops, bool_count

    def get_valid_int_operands(
            self,  x: int
    ) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        int_ops: list[SSAValue] = [
            op.results[0] for op in self.ops[:x]
            if (isinstance(op, SynthOperator) and op.res_type == SynthType.INT)
               or isinstance(op, (GetOp, SyOne, SyZero, SyAllOnes))
        ]
        int_count = len(int_ops)
        return int_ops, int_count

    def get_valid_bint_operands(
            self, x: int
    ) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        bint_ops: list[SSAValue] = [
            op.results[0] for op in self.ops[:x]
            if (isinstance(op, SynthOperator) and op.res_type == SynthType.BOUNDED_INT)
               or isinstance(op, (SyBitWidth,))
        ]
        bint_count = len(bint_ops)
        return bint_ops, bint_count











