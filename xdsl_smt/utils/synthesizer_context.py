from ..dialects.transfer import (
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
    # SetHighBitsOp,
    # SetLowBitsOp,
    # GetLowBitsOp,
    # GetBitWidthOp,
    # UMulOverflowOp,
    # SMinOp,
    # SMaxOp,
    # UMinOp,
    # UMaxOp,
    ShlOp,
    LShrOp,
    SelectOp,
)
from xdsl.pattern_rewriter import *
from typing import TypeVar, Generic
from xdsl.ir import Operation
import xdsl.dialects.arith as arith
import random

T = TypeVar("T")


class Collection(Generic[T]):
    """
    This class implements a data structure called Collection.
    It supports O(1) insert, delete and retrieve a random element.
    """

    lst: list[T]
    lst_len: int
    ele_to_index: dict[T, int]

    def __init__(self, lst: list[T]):
        self.lst = []
        self.ele_to_index = {}
        self.lst_len = 0
        for i, ele in enumerate(lst):
            self.lst.append(ele)
            self.ele_to_index[ele] = i
            self.lst_len += 1

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
            return random.choice(self.lst)
        return None

    def get_all_elements(self):
        return tuple(self.lst)

    def get_random_element_if(self, predicate: Callable[[T], bool]) -> T | None:
        idx = random.randint(0, self.lst_len - 1)
        for i in range(self.lst_len):
            if predicate(self.lst[idx]):
                return self.lst[idx]
            idx += 1
            idx %= self.lst_len
        return None


basic_int_ops = (NegOp, AndOp, OrOp, XorOp, AddOp, SubOp, SelectOp)
full_int_ops = (
    NegOp,
    AndOp,
    OrOp,
    XorOp,
    AddOp,
    SubOp,
    SelectOp,
    LShrOp,
    ShlOp,
    CountLOneOp,
    CountLZeroOp,
    CountROneOp,
    CountRZeroOp,
)
basic_i1_ops = (arith.AndI, arith.OrI, arith.XOrI, CmpOp)


class SynthesizerContext:
    cmp_flags: list[int]
    i1_ops: tuple
    int_ops: tuple

    def __init__(self):
        self.cmp_flags = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.i1_ops = basic_i1_ops
        self.int_ops = basic_int_ops

    def use_basic_int_ops(self):
        self.int_ops = basic_int_ops

    def use_full_int_ops(self):
        self.int_ops = full_int_ops

    def get_available_i1_ops(self):
        return self.i1_ops

    def get_available_int_ops(self):
        return self.int_ops

    def set_cmp_flags(self, cmp_flags: list[int]):
        assert len(cmp_flags) != 0
        for flag in cmp_flags:
            assert 0 <= flag and flag <= 9
        self.cmp_flags = cmp_flags

    def get_random_i1_op(
        self, int_vals: list[SSAValue], i1_vals: list[SSAValue]
    ) -> Operation:
        result_type = random.choice(self.i1_ops)
        if result_type == CmpOp:
            return CmpOp(int_vals[0], int_vals[1], random.choice(self.cmp_flags))
        return result_type(i1_vals[0], i1_vals[1])

    def get_random_int_op(
        self, int_vals: list[SSAValue], i1_vals: list[SSAValue]
    ) -> Operation:
        result_type = random.choice(self.int_ops)
        if result_type == SelectOp:
            return SelectOp(i1_vals[0], int_vals[0], int_vals[1])
        elif result_type == NegOp:
            return NegOp(int_vals[0])
        return result_type(int_vals[0], int_vals[1])
