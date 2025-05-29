import argparse
import sys
from typing import Callable

from xdsl.context import MLContext
from xdsl.dialects.builtin import i1, IntegerAttr, FunctionType, UnitAttr
from xdsl.parser import Parser
from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from xdsl_smt.utils.synthesizer_utils.mutation_program import MutationProgram
from xdsl_smt.utils.synthesizer_utils.synthesizer_context import (
    SynthesizerContext,
    is_int_op,
    set_ret_type,
    get_ret_type,
    not_in_main_body,
    get_op_with_signature,
)
from xdsl_smt.utils.synthesizer_utils.dsl_operators import INT_T, BOOL_T, BINT_T
from xdsl_smt.utils.synthesizer_utils.random import Random
from xdsl_smt.dialects.transfer import (
    AbstractValueType,
    TransIntegerType,
    GetOp,
    MakeOp,
    GetAllOnesOp,
    Constant,
    AndOp,
    CmpOp,
    AddOp,
    GetBitWidthOp,
)
import xdsl.dialects.arith as arith
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.ir import Operation, OpResult


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
    current: MutationProgram
    current_cmp: EvalResult
    context: SynthesizerContext
    random: Random
    compute_cost: Callable[[EvalResult], float]
    is_cond: bool

    def __init__(
        self,
        func: FuncOp,
        context: SynthesizerContext,
        compute_cost: Callable[[EvalResult], float],
        length: int,
        reset_init_program: bool = True,
        random_init_program: bool = True,
        is_cond: bool = False,
    ):
        self.is_cond = is_cond
        if is_cond:
            cond_type = FunctionType.from_lists(
                func.function_type.inputs,  # pyright: ignore [reportArgumentType]
                [i1],
            )
            func = FuncOp("cond", cond_type)

        self.context = context
        self.compute_cost = compute_cost
        self.random = context.get_random_class()
        if reset_init_program:
            self.current = self.construct_init_program(func, length)
            if random_init_program:
                self.reset_to_random_prog(length)

    def compute_current_cost(self):
        return self.compute_cost(self.current_cmp)

    def get_current(self):
        return self.current.func

    def accept_proposed(self, proposed_cmp: EvalResult):
        self.current.remove_history()
        self.current_cmp = proposed_cmp

    def reject_proposed(self):
        self.current.revert_operation()

    def replace_entire_operation(self, idx: int, history: bool):
        """
        Random pick an operation and replace it with a new one
        """
        old_op = self.current.ops[idx]
        valid_operands = {
            ty: self.current.get_valid_operands(idx, ty)
            for ty in [INT_T, BOOL_T, BINT_T]
        }
        new_op = None
        while new_op is None:
            new_op = self.context.get_random_op(get_ret_type(old_op), valid_operands)

        self.current.replace_operation(old_op, new_op, history)

    def replace_operand(self, idx: int, history: bool):
        op = self.current.ops[idx]
        new_op = op.clone()

        self.current.replace_operation(op, new_op, history)

        ith = self.context.random.randint(0, len(op.operands) - 1)
        op_w_sig = get_op_with_signature(op)

        vals = self.current.get_valid_operands(idx, op_w_sig[1][ith])

        success = False
        while not success:
            success = self.context.replace_operand(new_op, ith, vals)

    def construct_init_program(self, _func: FuncOp, length: int):
        func = _func.clone()
        block = func.body.block
        for op in block.ops:
            block.detach_op(op)

        if self.context.weighted:
            func.attributes["from_weighted_dsl"] = UnitAttr()

        # Part I: GetOp
        for arg in block.args:
            if isinstance(arg.type, AbstractValueType):
                for i, field_type in enumerate(arg.type.get_fields()):
                    op = GetOp(arg, i)
                    set_ret_type(op, INT_T)
                    block.add_op(op)

        assert isinstance(block.last_op, GetOp)
        tmp_int_ssavalue = block.last_op.results[0]

        # Part II: Constants
        true: arith.ConstantOp = arith.ConstantOp(
            IntegerAttr.from_int_and_width(1, 1), i1
        )
        set_ret_type(true, BOOL_T)
        false: arith.ConstantOp = arith.ConstantOp(
            IntegerAttr.from_int_and_width(0, 1), i1
        )
        set_ret_type(false, BOOL_T)
        all_ones = GetAllOnesOp(tmp_int_ssavalue)
        set_ret_type(all_ones, INT_T)
        zero = Constant(tmp_int_ssavalue, 0)
        set_ret_type(zero, INT_T)
        one = Constant(tmp_int_ssavalue, 1)
        set_ret_type(one, INT_T)
        zero_bint = Constant(tmp_int_ssavalue, 0)
        set_ret_type(zero_bint, BINT_T)
        one_bint = Constant(tmp_int_ssavalue, 1)
        set_ret_type(one_bint, BINT_T)
        get_bw = GetBitWidthOp(tmp_int_ssavalue)
        set_ret_type(get_bw, BINT_T)
        block.add_op(true)
        block.add_op(false)
        block.add_op(zero)
        block.add_op(one)
        block.add_op(all_ones)
        block.add_op(zero_bint)
        block.add_op(one_bint)
        block.add_op(get_bw)

        if not self.is_cond:
            # Part III: Main Body
            last_int_op = block.last_op
            for i in range(length):
                if i % 4 == 0:
                    nop_bool = CmpOp(tmp_int_ssavalue, tmp_int_ssavalue, 0)
                    set_ret_type(nop_bool, BOOL_T)
                    block.add_op(nop_bool)
                elif i % 4 == 1:
                    bint_nop = AddOp(tmp_int_ssavalue, tmp_int_ssavalue)
                    set_ret_type(bint_nop, BINT_T)
                    block.add_op(bint_nop)
                elif i % 4 == 2:
                    last_int_op = AndOp(tmp_int_ssavalue, tmp_int_ssavalue)
                    set_ret_type(last_int_op, INT_T)
                    block.add_op(last_int_op)
                else:
                    last_int_op = AndOp(tmp_int_ssavalue, tmp_int_ssavalue)
                    set_ret_type(last_int_op, INT_T)
                    block.add_op(last_int_op)

            # Part IV: MakeOp
            output = list(func.function_type.outputs)[0]
            assert isinstance(output, AbstractValueType)
            operands: list[OpResult] = []
            for i, field_type in enumerate(output.get_fields()):
                assert isinstance(field_type, TransIntegerType)
                assert last_int_op is not None
                operands.append(last_int_op.results[0])
                while True:
                    last_int_op = last_int_op.prev_op
                    assert last_int_op is not None
                    if is_int_op(last_int_op):
                        break

            return_val = MakeOp(operands)
            block.add_op(return_val)

        else:
            # Part III: Main Body
            last_bool_op = true
            for i in range(length):
                if i % 4 == 0:
                    last_int_op = AndOp(tmp_int_ssavalue, tmp_int_ssavalue)
                    set_ret_type(last_int_op, INT_T)
                    block.add_op(last_int_op)
                else:
                    last_bool_op = CmpOp(tmp_int_ssavalue, tmp_int_ssavalue, 0)
                    set_ret_type(last_bool_op, BOOL_T)
                    block.add_op(last_bool_op)

            return_val = last_bool_op.results[0]

        # Part V: Return
        block.add_op(ReturnOp(return_val))

        return MutationProgram(func)

    def sample_next(self):
        """
        Sample the next program.
        Return the new program with the proposal ratio.
        """

        live_ops = self.current.get_modifiable_operations()
        live_op_indices = [x[1] for x in live_ops]

        sample_mode = self.random.random()

        # replace an operation with a new operation
        if sample_mode < 0.3 and live_op_indices:
            idx = self.random.choice(live_op_indices)
            self.replace_entire_operation(idx, True)
        # replace an operand in an operation
        elif sample_mode < 1 and live_op_indices:
            idx = self.random.choice(live_op_indices)
            self.replace_operand(idx, True)
        # elif sample_mode < 1:
        #     # replace an operand in makeOp
        #     ratio = self.replace_make_operand(ops, len(ops) - 2)
        return self

    def reset_to_random_prog(self, length: int):
        # Part III-2: Random reset main body
        total_ops_len = len(self.current.ops)
        # Only modify ops in the main body
        for i in range(total_ops_len):
            if not not_in_main_body(self.current.ops[i]):
                self.replace_entire_operation(i, False)
