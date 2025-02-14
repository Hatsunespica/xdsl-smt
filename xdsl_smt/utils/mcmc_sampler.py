import argparse

from xdsl.context import MLContext
from xdsl.parser import Parser

from xdsl.utils.exceptions import VerifyException
from xdsl_smt.dialects import transfer
from xdsl_smt.utils.compare_result import CompareResult
from xdsl_smt.utils.synthesizer_context import SynthesizerContext
from xdsl_smt.utils.random import Random
from xdsl.dialects import arith
from xdsl_smt.dialects.transfer import (
    AbstractValueType,
    TransIntegerType,
    GetOp,
    MakeOp,
    GetAllOnesOp,
    Constant,
    GetBitWidthOp,
    AndOp,
    CountLOneOp,
)
from xdsl.dialects.builtin import (
    IntegerAttr,
    IntegerType,
    i1,
)
from xdsl.dialects.func import FuncOp, Return
from xdsl.ir import Operation, OpResult, SSAValue, Block
import sys as sys


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


class MCMCSampler:
    last_make_op: MakeOp
    current: FuncOp
    proposed: FuncOp | None
    current_cmp: CompareResult
    context: SynthesizerContext
    random: Random

    def __init__(
        self,
        func: FuncOp,
        context: SynthesizerContext,
        length: int,
        init_cost: float,
        reset: bool = True,
        init_cmp_res: CompareResult = CompareResult(0, 0, 0, 0, 0, 0, 0, 0),
    ):
        self.current = func.clone()
        self.proposed = None
        self.current_cmp = init_cmp_res
        self.context = context
        self.random = context.get_random_class()
        if reset:
            self.construct_init_program(self.current, length)

    def get_current(self):
        return self.current

    def get_proposed(self):
        return self.proposed

    def accept_proposed(self, proposed_cmp: CompareResult):
        assert self.proposed is not None
        self.current = self.proposed
        self.current_cmp = proposed_cmp
        self.proposed = None

    def reject_proposed(self):
        self.proposed = None

    # Todo[Xuanyu]: Find a general way to search ops with valid result types
    def is_i1_operation(self, op) -> bool:
        return (isinstance(op, arith.Constant)
                or op.results[0].type == i1)

    # Todo[Xuanyu]: Find a general way to search ops with valid result types
    def is_int_operation(self, op) -> bool:
        return (isinstance(op, Constant)
                or isinstance(op, GetOp)
                or (any(isinstance(op, op_type) for op_type in self.context.get_available_int_ops())))

    # Todo[Xuanyu]: Find a general way to search ops with valid result types
    def is_bint_operation(self, op) -> bool:
        return (isinstance(op, GetBitWidthOp)
                or any(isinstance(op, op_type) for op_type in self.context.get_available_bint_ops()))

    def get_valid_bool_operands(
        self, ops: list[Operation], x: int
    ) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        bool_ops: list[SSAValue] = [
            op.results[0] for op in ops[:x]
            if self.is_i1_operation(op)
            # for result in op.results if result.type == i1
        ]
        bool_count = len(bool_ops)
        return bool_ops, bool_count

    def get_valid_int_operands(
        self, ops: list[Operation], x: int
    ) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        int_ops: list[SSAValue] = [
            op.results[0]
            for op in ops[:x]
            if self.is_int_operation(op)
            # for result in op.results
            # if isinstance(result.type, TransIntegerType)
        ]
        int_count = len(int_ops)
        return int_ops, int_count

    def get_valid_bint_operands(
            self, ops: list[Operation], x: int
    ) -> tuple[list[SSAValue], int]:
        """
        Get operations that before ops[x] so that can serve as operands
        """
        bint_ops: list[SSAValue] = [
            op.results[0]
            for op in ops[:x]
            if self.is_bint_operation(op)
            # for result in op.results
            # if isinstance(result.type, TransIntegerType)
        ]
        bint_count = len(bint_ops)
        return bint_ops, bint_count

    def replace_entire_operation(
        self, block: Block, ops: list[Operation], idx: int
    ) -> float:
        """
        Random pick an operation and replace it with a new one
        """
        # idx = self.random.choice(live_op_indices)
        old_op = ops[idx]

        int_operands, num_int_operands = self.get_valid_int_operands(ops, idx)
        bool_operands, num_bool_operands = self.get_valid_bool_operands(ops, idx)
        bint_operands, num_bint_operands = self.get_valid_bint_operands(ops, idx)

        # def calculate_operand_prob(op: Operation) -> int:
        #     ret = 1
        #     for operand in op.operands:
        #         if operand.type == IntegerType(4):
        #             ret = ret * num_int_operands
        #         elif operand.type == i1:
        #             ret = ret * num_bool_operands
        #     return ret

        if self.is_i1_operation(old_op): # bool
            new_op = self.context.get_random_i1_op(int_operands, bool_operands)

        elif self.is_int_operation(old_op):  # integer
            new_op = self.context.get_random_int_op_except(
                int_operands, bool_operands, bint_operands, old_op
            )

        elif self.is_bint_operation(old_op):  # bounded_integer
            new_op = self.context.get_random_bint_op_except(
                int_operands, bool_operands, bint_operands, old_op
            )

        else:
            raise VerifyException(
                "Unexpected result type {}".format(old_op)
            )

        block.insert_op_before(new_op, old_op)
        if len(old_op.results) > 0 and len(new_op.results) > 0:
            old_op.results[0].replace_by(new_op.results[0])
        block.detach_op(old_op)

        return 1

    def replace_operand(self, ops: list[Operation], idx: int) -> float:
        op = ops[idx]
        int_operands, _ = self.get_valid_int_operands(ops, idx)
        bool_operands, _ = self.get_valid_bool_operands(ops, idx)
        bint_operands, _ = self.get_valid_bint_operands(ops, idx)

        ith = self.random.randint(0, len(op.operands) - 1)
        # Todo[Xuanyu]: Find a general way to determine the type of the operand
        ith_owner = op.operands[ith].owner
        if self.is_i1_operation(ith_owner):
            new_operand = self.random.choice(bool_operands)
        elif self.is_int_operation(ith_owner):
            new_operand = self.random.choice(int_operands)
        elif self.is_bint_operation(ith_owner):
            new_operand = self.random.choice(bint_operands)
        else:
            raise VerifyException(
                "Unexpected operand type {}".format(op.operands[ith].type)
            )

        op.operands[ith] = new_operand
        return 1

    def replace_make_operand(self, ops: list[Operation], make_op_idx: int) -> float:
        idx = make_op_idx
        op = ops[idx]
        assert isinstance(op, MakeOp)

        int_operands, _ = self.get_valid_int_operands(ops, idx)
        ith = self.random.randint(0, len(op.operands) - 1)
        assert isinstance(op.operands[ith].type, TransIntegerType)
        new_operand = self.random.choice(int_operands)
        op.operands[ith] = new_operand
        return 1

    def construct_init_program(self, func: FuncOp, length: int):
        block = func.body.block

        for op in block.ops:
            block.detach_op(op)

        # Part I: GetOp
        for arg in block.args:
            if isinstance(arg.type, AbstractValueType):
                for i, field_type in enumerate(arg.type.get_fields()):
                    op = GetOp(arg, i)
                    block.add_op(op)
        assert isinstance(block.last_op, GetOp)
        tmp_int_ssavalue = block.last_op.results[0]

        # Part II: Constants
        true: arith.Constant = arith.Constant(
            IntegerAttr.from_int_and_width(1, 1), i1
        )
        false: arith.Constant = arith.Constant(
            IntegerAttr.from_int_and_width(0, 1), i1
        )
        all_ones = GetAllOnesOp(tmp_int_ssavalue)
        # zero = Constant(tmp_int_ssavalue, 0)
        one = Constant(tmp_int_ssavalue, 1)
        bitw = GetBitWidthOp(tmp_int_ssavalue)
        # block.add_op(true)
        block.add_op(false)
        # block.add_op(zero)
        block.add_op(one)
        block.add_op(all_ones)
        block.add_op(bitw)

        # Part III: Main Body
        tmp_bool_ssavalue = false.results[0]
        assert length % 4 == 0, f"length must be divisible by 4"
        for i in range(length // 4):
            nop_int1 = AndOp(tmp_int_ssavalue, tmp_int_ssavalue)
            nop_int2 = AndOp(tmp_int_ssavalue, tmp_int_ssavalue)
            nop_bool = arith.AndI(tmp_bool_ssavalue, tmp_bool_ssavalue)
            nop_bounded_int = CountLOneOp(tmp_int_ssavalue)
            block.add_op(nop_bool)
            block.add_op(nop_int1)
            block.add_op(nop_bounded_int)
            block.add_op(nop_int2)


        # Part III-2: Random reset main body
        for i in range(length):
            ops = list(block.ops)
            tmp_ops_len = len(block.ops)
            self.replace_entire_operation(block, ops, tmp_ops_len - 1 - i)

        last_int_op = block.last_op

        # Part IV: MakeOp
        return_val: list[Operation] = []
        for output in func.function_type.outputs:
            assert isinstance(output, AbstractValueType)
            operands: list[OpResult] = []
            for i, field_type in enumerate(output.get_fields()):
                assert isinstance(field_type, TransIntegerType)
                assert last_int_op is not None
                operands.append(last_int_op.results[0])
                assert last_int_op.prev_op is not None
                last_int_op = last_int_op.prev_op.prev_op

            op = MakeOp(operands)
            block.add_op(op)
            return_val.append(op)

        # Part V: Return
        block.add_op(Return(return_val[0]))
        return

    @staticmethod
    def get_modifiable_operations(
        func: FuncOp, only_live: bool = True
    ) -> list[tuple[Operation, int]]:
        ops = list(func.body.block.ops)
        assert isinstance(ops[-1], Return)
        assert isinstance(ops[-2], MakeOp)
        last_make_op = ops[-2]

        live_set = set[Operation]()
        modifiable_ops = list[tuple[Operation, int]]()

        for operand in last_make_op.operands:
            assert isinstance(operand.owner, Operation)
            live_set.add(operand.owner)
        # live_set.add(last_make_op)

        def not_in_main_body(op: Operation):
            # filter out operations not belong to main body
            return (
                isinstance(operation, Constant)
                or isinstance(operation, arith.Constant)
                or isinstance(operation, GetAllOnesOp)
                or isinstance(operation, GetBitWidthOp)
                or isinstance(operation, GetOp)
                or isinstance(operation, MakeOp)
                or isinstance(operation, Return)
            )

        for idx in range(len(ops) - 3, -1, -1):
            operation = ops[idx]
            if not_in_main_body(operation):
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

    def sample_next(self) -> float:
        """
        Sample the next program.
        Return the new program with the proposal ratio.
        """
        self.proposed = self.current.clone()

        return_op = self.proposed.body.block.last_op
        assert isinstance(return_op, Return)
        last_make_op = return_op.operands[0].owner
        assert isinstance(last_make_op, MakeOp)

        live_ops = self.get_modifiable_operations(self.proposed)
        live_op_indices = [_[1] for _ in live_ops]

        ops = list(self.proposed.body.block.ops)

        sample_mode = self.random.random()
        if sample_mode < 0.3 and live_op_indices:
            # replace an operation with a new operation
            idx = self.random.choice(live_op_indices)
            ratio = self.replace_entire_operation(self.proposed.body.block, ops, idx)

        elif sample_mode < 1 and live_op_indices:
            # replace an operand in an operation
            idx = self.random.choice(live_op_indices)
            ratio = self.replace_operand(ops, idx)

        elif sample_mode < 1:
            # replace an operand in makeOp
            ratio = self.replace_make_operand(ops, len(ops) - 2)
        else:
            # todo: replace an operations with NOP
            ratio = 1

        return ratio
