import argparse

from xdsl.context import MLContext
from xdsl.parser import Parser

from xdsl.utils.exceptions import VerifyException
from xdsl_smt.utils.compare_result import CompareResult
from xdsl_smt.utils.mutation_program import MutationProgram
from xdsl_smt.utils.synth_operators import (
    SyFalse,
    SyZero,
    SyTrue,
    SyOne,
    SyAllOnes,
    SyBitWidth,
    SyAnd,
    # SyAndI,
    SyCountLZero,
    SynthOperator,
    SynthType,
    SyEq,
)
from xdsl_smt.utils.synthesizer_context import SynthesizerContext
from xdsl_smt.utils.random import Random
from xdsl_smt.dialects.transfer import (
    AbstractValueType,
    TransIntegerType,
    GetOp,
    MakeOp,
)
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.ir import Operation, OpResult
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
    current: MutationProgram
    proposed: MutationProgram | None
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
        if reset:
            self.current = self.construct_init_program(func, length)
        else:
            self.current = MutationProgram(func.clone())
        self.proposed = None
        self.current_cmp = init_cmp_res
        self.context = context
        self.random = context.get_random_class()

    def get_current(self):
        return self.current.func

    def get_proposed(self):
        if self.proposed is None:
            return None
        return self.proposed.func

    def accept_proposed(self, proposed_cmp: CompareResult):
        assert self.proposed is not None
        self.current = self.proposed
        self.current_cmp = proposed_cmp
        self.proposed = None

    def reject_proposed(self):
        self.proposed = None

    def replace_entire_operation(self, prog: MutationProgram, idx: int) -> float:
        """
        Random pick an operation and replace it with a new one
        """
        old_op = prog.ops[idx]
        int_operands, _ = prog.get_valid_int_operands(idx)
        bool_operands, _ = prog.get_valid_bool_operands(idx)
        bint_operands, _ = prog.get_valid_bint_operands(idx)

        assert isinstance(
            old_op, SynthOperator
        ), f"The operation cannot be mutated: {old_op}"

        new_op = None
        while new_op is None:
            if old_op.res_type == SynthType.BOOL:  # bool
                new_op = self.context.get_random_i1_op(
                    int_operands, bool_operands, bint_operands
                )
            elif old_op.res_type == SynthType.INT:  # integer
                new_op = self.context.get_random_int_op(
                    int_operands, bool_operands, bint_operands
                )
            elif old_op.res_type == SynthType.BOUNDED_INT:  # bounded_integer
                new_op = self.context.get_random_bint_op(
                    int_operands, bool_operands, bint_operands
                )
            else:
                raise VerifyException("Unexpected result type {}".format(old_op))
        prog.replace_operation(old_op, new_op)
        return 1

    def replace_operand(self, prog: MutationProgram, idx: int) -> float:
        op = prog.ops[idx]
        int_operands, _ = prog.get_valid_int_operands(idx)
        bool_operands, _ = prog.get_valid_bool_operands(idx)
        bint_operands, _ = prog.get_valid_bint_operands(idx)
        assert isinstance(op, SynthOperator), f"The operation cannot be mutated: {op}"

        success = False
        while not success:
            success = op.replace_an_operand(
                self.random, int_operands, bool_operands, bint_operands
            )

        return 1

    # def replace_make_operand(self, ops: list[Operation], make_op_idx: int) -> float:
    #     idx = make_op_idx
    #     op = ops[idx]
    #     assert isinstance(op, MakeOp)
    #
    #     int_operands, _ = self.get_valid_int_operands(ops, idx)
    #     ith = self.random.randint(0, len(op.operands) - 1)
    #     assert isinstance(op.operands[ith].type, TransIntegerType)
    #     new_operand = self.random.choice(int_operands)
    #     op.operands[ith] = new_operand
    #     return 1

    def construct_init_program(self, _func: FuncOp, length: int):
        func = _func.clone()
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
        false_op = SyFalse()
        block.add_op(SyTrue())
        block.add_op(false_op)
        block.add_op(SyZero(tmp_int_ssavalue))
        block.add_op(SyOne(tmp_int_ssavalue))
        block.add_op(SyAllOnes(tmp_int_ssavalue))
        block.add_op(SyBitWidth(tmp_int_ssavalue))

        # Part III: Main Body
        # tmp_bool_ssavalue = false_op.results[0]
        for i in range(length // 4):
            nop_int1 = SyAnd(tmp_int_ssavalue, tmp_int_ssavalue)
            nop_int2 = SyAnd(tmp_int_ssavalue, tmp_int_ssavalue)
            nop_bool = SyEq(tmp_int_ssavalue, tmp_int_ssavalue)
            nop_bounded_int = SyCountLZero(tmp_int_ssavalue)
            block.add_op(nop_bool)
            block.add_op(nop_int1)
            block.add_op(nop_bounded_int)
            block.add_op(nop_int2)

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
        block.add_op(ReturnOp(return_val[0]))

        return MutationProgram(func)

    def sample_next(self) -> float:
        """
        Sample the next program.
        Return the new program with the proposal ratio.
        """
        self.proposed = self.current.clone()

        # return_op = self.proposed.body.block.last_op
        # assert isinstance(return_op, Return)
        # last_make_op = return_op.operands[0].owner
        # assert isinstance(last_make_op, MakeOp)

        live_ops = self.proposed.get_modifiable_operations()
        live_op_indices = [_[1] for _ in live_ops]

        sample_mode = self.random.random()
        if (
            sample_mode < 0.3 and live_op_indices
        ):  # replace an operation with a new operation
            idx = self.random.choice(live_op_indices)
            ratio = self.replace_entire_operation(self.proposed, idx)
        elif sample_mode < 1 and live_op_indices:  # replace an operand in an operation
            idx = self.random.choice(live_op_indices)
            ratio = self.replace_operand(self.proposed, idx)
        # elif sample_mode < 1:
        #     # replace an operand in makeOp
        #     ratio = self.replace_make_operand(ops, len(ops) - 2)
        else:
            ratio = 1

        return ratio

    def reset_to_random_prog(self):
        # Part III-2: Random reset main body
        ops = self.current.ops

        for i, op in enumerate(ops):
            if isinstance(op, SynthOperator):
                self.replace_entire_operation(self.current, i)
