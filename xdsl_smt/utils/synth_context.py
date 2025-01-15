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

T = TypeVar("T", covariant=True)


class Collection(Generic[T]):
    """
    This class implements a data structure called Collection.
    It supports O(1) insert, delete and retrieve a random element.
    """

    lst: list[T]
    lst_len: int
    ele_to_index: dict[T, int]

    def __init__(self, lst: list[T]):
        self.lst = lst
        self.ele_to_index = {}
        self.lst_len = len(lst)
        for i, ele in enumerate(lst):
            self.ele_to_index[ele] = i

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

    def get_all_elements(self) -> tuple[T, ...]:
        return tuple(self.lst)

    def get_random_element_if(self, predicate: Callable[[T], bool]) -> T | None:
        idx = random.randint(0, self.lst_len - 1)
        for i in range(self.lst_len):
            if predicate(self.lst[idx]):
                return self.lst[idx]
            idx += 1
            idx %= self.lst_len
        return None
