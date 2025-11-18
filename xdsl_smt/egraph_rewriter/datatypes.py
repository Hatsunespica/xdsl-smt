from __future__ import annotations
from typing import Callable
from egglog import birewrite, i64Like, StringLike, Expr, rewrite, ruleset, vars_, method

from xdsl_smt.dialects.transfer import AddOp, AndOp, NegOp, OrOp, SubOp, XorOp
from xdsl.ir import Operation


class BV(Expr):
    @method(cost=0)
    def __init__(self, value: i64Like) -> None:
        ...

    @method(cost=0)
    @classmethod
    def var(cls, name: StringLike) -> BV:
        ...

    # For some reason, the override for __or__ does not work
    # def __or__(self, other: Num) -> Num: ...

    @classmethod
    def Or(cls, lhs: BV, rhs: BV) -> BV:
        ...

    @classmethod
    def Neg(cls, operand: BV) -> BV:
        ...

    def __add__(self, other: BV) -> BV:
        ...

    def __mul__(self, other: BV) -> BV:
        ...

    def __sub__(self, other: BV) -> BV:
        ...

    def __and__(self, other: BV) -> BV:
        ...

    def __xor__(self, other: BV) -> BV:
        ...


mlir_op_to_egraph_op: dict[type[Operation], Callable[..., BV]] = {
    AddOp: BV.__add__,
    SubOp: BV.__sub__,
    AndOp: BV.__and__,
    OrOp: BV.Or,
    XorOp: BV.__xor__,
    NegOp: BV.Neg,
}


def gen_ruleset():
    x, y, z = vars_("x y z", BV)
    return ruleset(
        # For KnownBits Domain
        rewrite(BV.var("arg0_0") & BV.var("arg0_1")).to(BV(0)),
        rewrite(BV.var("arg1_0") & BV.var("arg1_1")).to(BV(0)),
        birewrite(BV.var("arg0_0") + BV.var("arg0_1")).to(
            BV.Or(BV.var("arg0_0"), BV.var("arg0_1"))
        ),
        birewrite(BV.var("arg1_0") + BV.var("arg1_1")).to(
            BV.Or(BV.var("arg1_0"), BV.var("arg1_1"))
        ),
        # Bitvector Algebra - Idempotent laws
        rewrite(x & x).to(x),
        rewrite(BV.Or(x, x)).to(x),
        rewrite(x ^ x).to(BV(0)),
        # Commutativity
        rewrite(x + y).to(y + x),
        rewrite(x & y).to(y & x),
        rewrite(BV.Or(x, y)).to(BV.Or(y, x)),
        rewrite(x ^ y).to(y ^ x),
        rewrite(x * y).to(y * x),
        # Identity elements
        rewrite(x + BV(0)).to(x),
        rewrite(x * BV(1)).to(x),
        rewrite(x & BV(-1)).to(x),  # x & all_ones = x
        rewrite(BV.Or(x, BV(0))).to(x),
        rewrite(x ^ BV(0)).to(x),
        # Absorbing elements
        rewrite(x * BV(0)).to(BV(0)),
        rewrite(x & BV(0)).to(BV(0)),
        rewrite(BV.Or(x, BV(-1))).to(BV(-1)),  # x | all_ones = all_ones
        # Associativity (useful for normalization)
        birewrite((x + y) + z).to(x + (y + z)),
        birewrite((x * y) * z).to(x * (y * z)),
        birewrite((x & y) & z).to(x & (y & z)),
        birewrite(BV.Or(BV.Or(x, y), z)).to(BV.Or(x, BV.Or(y, z))),
        birewrite((x ^ y) ^ z).to(x ^ (y ^ z)),
        # Distributivity
        rewrite(x & (y ^ z)).to((x & y) ^ (x & z)),
        rewrite(BV.Or(x, (y & z))).to(BV.Or(x, y) & BV.Or(x, z)),
        rewrite(BV.Or(x, y) & z).to(BV.Or(x & z, y & z)),
        # AND/OR relationships
        rewrite(x & BV.Or(x, y)).to(x),  # absorption law
        rewrite(BV.Or(x, (x & y))).to(x),  # absorption law
        # Subtraction properties
        rewrite(x - x).to(BV(0)),
        rewrite(x - BV(0)).to(x),
        birewrite(BV(-1) - x).to(BV.Neg(x)),
        birewrite(x ^ BV(-1)).to(BV.Neg(x)),  # x ^ all_ones = ~x
        # Negation properties (arithmetic negation)
        rewrite(BV.Neg(BV.Neg(x))).to(x),  # double negation
        rewrite(x + BV.Neg(x)).to(BV(-1)),  # x + (~x) = all_ones
        rewrite(x & BV.Neg(x)).to(BV(0)),  # x & (~x) = 0
        rewrite(x ^ BV.Neg(x)).to(BV(-1)),  # x ^ (~x) = all_ones
        # Advanced patterns
        rewrite((x + y) - y).to(x),  # (x + y) - y = x (when no overflow)
        rewrite((x - y) + y).to(x),  # (x - y) + y = x (when no overflow)
        # Constant folding
        rewrite(BV(1) + BV(-1)).to(BV(0)),
        name="my_ruleset",
    )
