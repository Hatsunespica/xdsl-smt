from xdsl.dialects.builtin import IntegerAttr, StringAttr, ArrayAttr
from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.utils.hints import isa

from xdsl_smt.dialects.transfer import (
    NegOp,
    CmpOp,
    AndOp,
    OrOp,
    XorOp,
    AddOp,
    SubOp,
    CountLOneOp,
    CountLZeroOp,
    CountROneOp,
    CountRZeroOp,
    GetBitWidthOp,
    # GetSignedMinValueOp,
    # GetSignedMaxValueOp,
    # UMulOverflowOp,
    SMinOp,
    SMaxOp,
    UMinOp,
    UMaxOp,
    ShlOp,
    LShrOp,
    SelectOp,
    UnaryOp,
    Constant,
    GetAllOnesOp,
    MulOp,
    SetLowBitsOp,
    SetHighBitsOp,
    ClearHighBitsOp,
    ClearLowBitsOp,
    SetSignBitOp,
    ClearSignBitOp,
    GetOp,
    MakeOp,
)
from typing import TypeVar, Generic, Callable
from xdsl.ir import Operation, SSAValue, Attribute
import xdsl.dialects.arith as arith
from xdsl_smt.utils.synthesizer_utils.random import Random

T = TypeVar("T")


class Collection(Generic[T]):
    """
    This class implements a data structure called Collection.
    It supports O(1) insert, delete and retrieve a random element.
    """

    lst: list[T]
    lst_len: int
    ele_to_index: dict[T, int]
    random: Random

    def __init__(self, lst: list[T], random: Random):
        self.lst = lst
        self.ele_to_index = {}
        self.lst_len = len(lst)
        for i, ele in enumerate(lst):
            self.ele_to_index[ele] = i
        self.random = random

    def add(self, ele: T):
        self.lst.append(ele)
        self.lst_len += 1
        self.ele_to_index[ele] = self.lst_len

    def remove(self, ele: T):
        if ele in self.ele_to_index:
            idx = self.ele_to_index[ele]
            self.lst[idx] = self.lst[-1]
            self.lst.pop()
            self.lst_len -= 1
            del self.ele_to_index[ele]

    def size(self):
        return self.lst_len

    def get_random_element(self) -> T | None:
        if self.lst_len != 0:
            return self.random.choice(self.lst)
        return None

    def get_weighted_random_element(self, weights: dict[T, int]) -> T | None:
        if self.lst_len != 0:
            return self.random.choice_weighted(self.lst, weights=weights)
        return None

    def get_all_elements(self) -> tuple[T, ...]:
        return tuple(self.lst)

    def get_random_element_if(self, predicate: Callable[[T], bool]) -> T | None:
        idx = self.random.randint(0, self.lst_len - 1)
        for _ in range(self.lst_len):
            if predicate(self.lst[idx]):
                return self.lst[idx]
            idx += 1
            idx %= self.lst_len
        return None


enable_bint = True
INT_T = "int"
BOOL_T = "bool"
BINT_T = "bint" if enable_bint else "int"
OpWithSignature = tuple[type[Operation], tuple[str, ...]]

full_bint_ops: list[OpWithSignature] = [
    (AddOp, (BINT_T, BINT_T)),
    (SubOp, (BINT_T, BINT_T)),
    (SelectOp, (BOOL_T, BINT_T, BINT_T)),
    (UMinOp, (BINT_T, BINT_T)),
    (UMaxOp, (BINT_T, BINT_T)),
    (CountLOneOp, (INT_T,)),
    (CountLZeroOp, (INT_T,)),
    (CountROneOp, (INT_T,)),
    (CountRZeroOp, (INT_T,)),
]


basic_int_ops: list[OpWithSignature] = [
    (NegOp, (INT_T,)),
    (AndOp, (INT_T, INT_T)),
    (OrOp, (INT_T, INT_T)),
    (XorOp, (INT_T, INT_T)),
    (AddOp, (INT_T, INT_T)),
    # (AddOp, BINT_T, [BINT_T, BINT_T]),
    # SubOp,
    # SelectOp,
]


full_int_ops: list[OpWithSignature] = [
    (NegOp, (INT_T,)),
    (AndOp, (INT_T, INT_T)),
    (OrOp, (INT_T, INT_T)),
    (XorOp, (INT_T, INT_T)),
    (AddOp, (INT_T, INT_T)),
    (SubOp, (INT_T, INT_T)),
    (SelectOp, (BOOL_T, INT_T, INT_T)),
    (LShrOp, (INT_T, BINT_T)),
    (ShlOp, (INT_T, BINT_T)),
    (UMinOp, (INT_T, INT_T)),
    (UMaxOp, (INT_T, INT_T)),
    (SMinOp, (INT_T, INT_T)),
    (SMaxOp, (INT_T, INT_T)),
    (MulOp, (INT_T, INT_T)),
    (SetHighBitsOp, (INT_T, BINT_T)),
    (SetLowBitsOp, (INT_T, BINT_T)),
    (ClearHighBitsOp, (INT_T, BINT_T)),
    (ClearLowBitsOp, (INT_T, BINT_T)),
    (SetSignBitOp, (INT_T,)),
    (ClearSignBitOp, (INT_T,)),
]

if not enable_bint:
    full_int_ops = list(set(full_int_ops + full_bint_ops))


full_i1_ops: list[OpWithSignature] = [
    (arith.AndIOp, (BOOL_T, BOOL_T)),
    (arith.OrIOp, (BOOL_T, BOOL_T)),
    (arith.XOrIOp, (BOOL_T, BOOL_T)),
    (CmpOp, (INT_T, INT_T)),
    (CmpOp, (BINT_T, BINT_T)),
]

basic_i1_ops: list[OpWithSignature] = [
    (CmpOp, (INT_T, INT_T)),
    (CmpOp, (BINT_T, BINT_T)),
]


def is_constant_constructor(constants: list[int]) -> Callable[[SSAValue], bool]:
    is_constant: Callable[[SSAValue], bool] = lambda val=SSAValue: (
        isinstance(val.owner, Constant) and val.owner.value.value.data in constants
    )
    return is_constant


is_zero_or_one: Callable[[SSAValue], bool] = is_constant_constructor([0, 1])

is_zero: Callable[[SSAValue], bool] = is_constant_constructor([0])

is_one: Callable[[SSAValue], bool] = is_constant_constructor([1])

is_true: Callable[[SSAValue], bool] = lambda val=SSAValue: (
    isinstance(val.owner, arith.ConstantOp)
    and isinstance(val.owner.value, IntegerAttr)
    and val.owner.value.value.data == 1
)

is_false: Callable[[SSAValue], bool] = lambda val=SSAValue: (
    isinstance(val.owner, arith.ConstantOp)
    and isinstance(val.owner.value, IntegerAttr)
    and val.owner.value.value.data == 0
)

is_constant_bool: Callable[[SSAValue], bool] = lambda val=SSAValue: isinstance(
    val.owner, arith.ConstantOp
)


def is_allones(val: SSAValue) -> bool:
    return isinstance(val.owner, GetAllOnesOp)


def is_get_bitwidth(val: SSAValue) -> bool:
    return isinstance(val.owner, GetBitWidthOp)


def is_zero_or_allones(val: SSAValue) -> bool:
    return is_allones(val) or is_zero(val)


def is_one_or_allones(val: SSAValue) -> bool:
    return is_allones(val) or is_one(val)


def is_zero_or_one_or_allones(val: SSAValue) -> bool:
    return is_allones(val) or is_zero_or_one(val)


def no_constraint(val: SSAValue) -> bool:
    return False


"""
Two dictionaries maintains optimizations on operand selection.
True value means we should not use that SSAValue as the operand
"""

optimize_operands_selection: dict[type[Operation], Callable[[SSAValue], bool]] = {
    # Transfer operations
    NegOp: is_zero_or_allones,
    AddOp: is_zero,
    SubOp: is_zero,
    MulOp: is_zero_or_one,
    AndOp: is_zero_or_allones,
    OrOp: is_zero_or_allones,
    XorOp: is_zero_or_allones,
    CountLZeroOp: is_zero_or_one_or_allones,
    CountRZeroOp: is_zero_or_one_or_allones,
    CountLOneOp: is_zero_or_one_or_allones,
    CountROneOp: is_zero_or_one_or_allones,
    ShlOp: is_zero_or_allones,
    LShrOp: is_zero_or_allones,
    UMaxOp: is_zero_or_allones,
    UMinOp: is_zero_or_allones,
    ClearSignBitOp: is_zero,
    SetSignBitOp: is_one_or_allones,
    # arith operations
    arith.AndIOp: is_constant_bool,
    arith.OrIOp: is_constant_bool,
    arith.XOrIOp: is_constant_bool,
}


"""
Complex selection mechanism.
For each operand we should have a predicate.
"""

optimize_complex_operands_selection: dict[
    type[Operation], list[Callable[[SSAValue], bool]]
] = {
    SelectOp: [is_constant_bool, no_constraint, no_constraint],
    SetLowBitsOp: [is_one_or_allones, is_zero_or_allones],
    SetHighBitsOp: [is_allones, is_zero_or_allones],
    ClearLowBitsOp: [is_zero, is_zero_or_allones],
    ClearHighBitsOp: [is_zero, is_zero_or_allones],
}

"""
Idempotent property means we should not use the same operand for both operand.
"""

idempotent_operations: set[type[Operation]] = {
    # Transfer operations
    SubOp,
    AndOp,
    OrOp,
    XorOp,
    CmpOp,
    UMaxOp,
    UMinOp,
    SMinOp,
    SMaxOp,
    # Special case for true and false branch
    SelectOp,
    # arith operations
    arith.AndIOp,
    arith.OrIOp,
    arith.XOrIOp,
}


def set_ret_type(op: Operation, ret_type: str):
    op.attributes["ret_type"] = StringAttr(ret_type)


def set_signature_attr(op: Operation, sig: OpWithSignature, ret_type: str):
    set_ret_type(op, ret_type)
    op.attributes["input_type"] = ArrayAttr(StringAttr(ty) for ty in sig[1])


def get_ret_type(op: Operation) -> str:
    assert "ret_type" in op.attributes
    assert isa(ret_type := op.attributes["ret_type"], StringAttr)
    return ret_type.data


def get_op_with_signature(op: Operation) -> OpWithSignature:
    assert "input_type" in op.attributes
    assert isa(input_type := op.attributes["input_type"], ArrayAttr[Attribute])
    sig: list[str] = []
    for ty in input_type.data:
        assert isa(ty, StringAttr)
        sig.append(ty.data)
    return type(op), tuple(sig)


def is_int_op(op: Operation) -> bool:
    return get_ret_type(op) == INT_T


def is_i1_op(op: Operation) -> bool:
    return get_ret_type(op) == BOOL_T


def is_bint_op(op: Operation) -> bool:
    return get_ret_type(op) == BINT_T


def is_of_type(op: Operation, ty: str) -> bool:
    return get_ret_type(op) == ty


def not_in_main_body(op: Operation):
    # filter out operations not belong to main body
    return (
        isinstance(op, Constant)
        or isinstance(op, arith.ConstantOp)
        or isinstance(op, GetAllOnesOp)
        or isinstance(op, GetBitWidthOp)
        or isinstance(op, GetOp)
        or isinstance(op, MakeOp)
        or isinstance(op, ReturnOp)
    )


class SynthesizerContext:
    random: Random
    cmp_flags: list[int]
    dsl_ops: dict[str, Collection[OpWithSignature]]
    op_weights: dict[str, dict[OpWithSignature, int]]
    weighted: bool
    commutative: bool = False
    idempotent: bool = True
    skip_trivial: bool = True

    def __init__(
        self,
        random: Random,
        weighted: bool = False,
    ):
        self.random = random
        self.cmp_flags = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.dsl_ops = dict()
        self.op_weights = dict()
        self.dsl_ops[BOOL_T] = Collection(basic_i1_ops, self.random)
        self.dsl_ops[INT_T] = Collection(basic_int_ops, self.random)
        self.op_weights[BOOL_T] = {key: 1 for key in basic_i1_ops}
        self.op_weights[INT_T] = {key: 1 for key in basic_int_ops}
        if enable_bint:
            self.dsl_ops[BINT_T] = Collection(full_bint_ops, self.random)
            self.op_weights[BINT_T] = {key: 1 for key in full_bint_ops}

        self.weighted = weighted

    def use_basic_int_ops(self):
        self.dsl_ops[INT_T] = Collection(basic_int_ops, self.random)
        self.op_weights[INT_T] = {key: 1 for key in basic_int_ops}

    def use_full_int_ops(self):
        self.dsl_ops[INT_T] = Collection(full_int_ops, self.random)
        self.op_weights[INT_T] = {key: 1 for key in full_int_ops}

    def use_basic_i1_ops(self):
        self.dsl_ops[BOOL_T] = Collection(basic_i1_ops, self.random)
        self.op_weights[BOOL_T] = {key: 1 for key in basic_i1_ops}

    def use_full_i1_ops(self):
        self.dsl_ops[BOOL_T] = Collection(full_i1_ops, self.random)
        self.op_weights[BOOL_T] = {key: 1 for key in full_i1_ops}

    def update_weights(self, frequency: dict[str, dict[OpWithSignature, int]]):
        for ty, freq in frequency.items():
            self.op_weights[ty] = {
                key: 1 for key in self.dsl_ops[ty].get_all_elements()
            }
            for key, val in freq.items():
                assert key in self.op_weights[ty]
                self.op_weights[ty][key] += val

    def set_cmp_flags(self, cmp_flags: list[int]):
        assert len(cmp_flags) != 0
        for flag in cmp_flags:
            assert 0 <= flag and flag <= 9
        self.cmp_flags = cmp_flags

    def get_random_class(self) -> Random:
        return self.random

    def get_constraint(self, op: type[Operation]) -> Callable[[SSAValue], bool]:
        if self.skip_trivial:
            return optimize_operands_selection.get(op, no_constraint)
        return no_constraint

    def is_idempotent(self, op: type[Operation]) -> bool:
        if self.idempotent:
            return op in idempotent_operations
        return False

    def select_operand(
        self,
        vals: list[SSAValue],
        constraint: Callable[[SSAValue], bool],
        exclude_val: SSAValue | None = None,
    ) -> SSAValue | None:
        current_pos = self.random.randint(0, len(vals) - 1)
        for _ in range(len(vals)):
            if not constraint(vals[current_pos]) and vals[current_pos] != exclude_val:
                return vals[current_pos]
            current_pos += 1
            current_pos %= len(vals)
        return None

    def select_two_operand(
        self,
        vals1: list[SSAValue],
        vals2: list[SSAValue],
        constraint1: Callable[[SSAValue], bool],
        constraint2: Callable[[SSAValue], bool] | None = None,
        is_idempotent: bool = False,
    ) -> tuple[SSAValue | None, SSAValue | None]:
        val1 = self.select_operand(vals1, constraint1)
        if val1 is None:
            return None, None
        if constraint2 is None:
            constraint2 = constraint1
        if is_idempotent:
            val2 = self.select_operand(vals2, constraint2, val1)
        else:
            val2 = self.select_operand(vals2, constraint2)
        return val1, val2

    def build_i1_op(
        self, result_type: type[Operation], operands_vals: tuple[list[SSAValue], ...]
    ) -> Operation | None:
        if result_type == CmpOp:
            val1, val2 = self.select_two_operand(
                operands_vals[0],
                operands_vals[1],
                self.get_constraint(result_type),
                is_idempotent=self.is_idempotent(result_type),
            )
            if val1 is None or val2 is None:
                return None
            return CmpOp(
                val1,
                val2,
                self.random.choice(self.cmp_flags),
            )
        assert result_type is not None
        val1, val2 = self.select_two_operand(
            operands_vals[0],
            operands_vals[1],
            self.get_constraint(result_type),
            is_idempotent=self.is_idempotent(result_type),
        )
        if val1 is None or val2 is None:
            return None
        result = result_type(
            val1,  # pyright: ignore [reportCallIssue]
            val2,
        )
        assert isinstance(result, Operation)
        return result

    def build_int_op(
        self,
        result_type: type[Operation],
        operands_vals: tuple[list[SSAValue], ...],
    ) -> Operation | None:
        assert result_type is not None
        if result_type == SelectOp:
            (
                cond_constraint,
                true_constraint,
                false_constraint,
            ) = optimize_complex_operands_selection[SelectOp]
            cond = self.select_operand(operands_vals[0], cond_constraint)
            true_val, false_val = self.select_two_operand(
                operands_vals[1],
                operands_vals[2],
                true_constraint,
                false_constraint,
                is_idempotent=self.is_idempotent(result_type),
            )
            if cond is None or true_val is None or false_val is None:
                return None
            return SelectOp(cond, true_val, false_val)
        elif issubclass(result_type, UnaryOp):
            val = self.select_operand(
                operands_vals[0], self.get_constraint(result_type)
            )
            if val is None:
                return None
            return result_type(val)  # pyright: ignore [reportCallIssue]
        elif self.skip_trivial and result_type in optimize_complex_operands_selection:
            constraint1, constraint2 = optimize_complex_operands_selection[result_type]
            val1, val2 = self.select_two_operand(
                operands_vals[0],
                operands_vals[1],
                constraint1,
                constraint2,
                is_idempotent=self.is_idempotent(result_type),
            )
        else:
            val1, val2 = self.select_two_operand(
                operands_vals[0],
                operands_vals[1],
                self.get_constraint(result_type),
                is_idempotent=self.is_idempotent(result_type),
            )

        if val1 is None or val2 is None:
            return None
        result = result_type(
            val1,  # pyright: ignore [reportCallIssue]
            val2,
        )
        assert isinstance(result, Operation)
        return result

    def get_random_op(
        self,
        op_type: str,
        vals: dict[str, list[SSAValue]],
    ) -> Operation | None:
        result_op_w_sig = (
            self.dsl_ops[op_type].get_weighted_random_element(self.op_weights[op_type])
            if self.weighted
            else self.dsl_ops[op_type].get_random_element()
        )

        assert result_op_w_sig is not None
        operands_vals = tuple(vals[t] for t in result_op_w_sig[1])
        if op_type == BOOL_T:
            ret_op = self.build_i1_op(result_op_w_sig[0], operands_vals)
        elif op_type == INT_T or op_type == BINT_T:
            ret_op = self.build_int_op(result_op_w_sig[0], operands_vals)
        else:
            assert False
        if ret_op is not None:
            set_signature_attr(ret_op, result_op_w_sig, op_type)
        return ret_op

    def replace_operand(self, op: Operation, ith: int, vals: list[SSAValue]):
        if not self.skip_trivial:
            # NOTICE: consider not the same value?
            val = self.select_operand(vals, no_constraint)
            if val is None:
                return False
            op.operands[ith] = val
            return True
        op_type = type(op)
        constraint: Callable[[SSAValue], bool] = self.get_constraint(op_type)
        if op_type in optimize_complex_operands_selection:
            constraint = optimize_complex_operands_selection[op_type][ith]

        is_idempotent = self.is_idempotent(op_type)
        new_constraint: Callable[[SSAValue], bool] | None = None
        if is_idempotent:
            # not the condition variable of select op
            if op_type == SelectOp and ith != 0:
                # 3 - ith -> given ith, select the other branch
                new_constraint = lambda val=SSAValue: (
                    constraint(val) and val != op.operands[3 - ith]
                )
            else:
                new_constraint = lambda val=SSAValue: (
                    constraint(val) and val != op.operands[1 - ith]
                )
        val = self.select_operand(
            vals, constraint if new_constraint is None else new_constraint
        )
        if val is None:
            return False
        op.operands[ith] = val
        return True

    @staticmethod
    def count_op_frequency(
        funcs: list[FuncOp],
    ) -> dict[str, dict[OpWithSignature, int]]:
        freq: dict[str, dict[OpWithSignature, int]] = {
            INT_T: {},
            BOOL_T: {},
            BINT_T: {},
        }
        for func in funcs:
            for op in func.body.block.ops:
                if not_in_main_body(op):
                    continue
                op_w_sig = get_op_with_signature(op)
                if op_w_sig in full_int_ops:
                    freq[INT_T][op_w_sig] = freq[INT_T].get(op_w_sig, 0) + 1
                if op_w_sig in full_i1_ops:
                    freq[BOOL_T][op_w_sig] = freq[BOOL_T].get(op_w_sig, 0) + 1
                if enable_bint and op_w_sig in full_bint_ops:
                    freq[BINT_T][op_w_sig] = freq[BINT_T].get(op_w_sig, 0) + 1
        return freq
