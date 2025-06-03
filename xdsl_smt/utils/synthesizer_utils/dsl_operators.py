from xdsl.dialects import arith
from xdsl.ir import Operation

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
    # GetBitWidthOp,
    # UMulOverflowOp,
    # SMinOp,
    # SMaxOp,
    UMinOp,
    UMaxOp,
    ShlOp,
    LShrOp,
    SelectOp,
    # UnaryOp,
    # Constant,
    # GetAllOnesOp,
    MulOp,
    SMinOp,
    SMaxOp,
    SetHighBitsOp,
    SetLowBitsOp,
    ClearHighBitsOp,
    ClearLowBitsOp,
    SetSignBitOp,
    ClearSignBitOp,
    UDivOp,
    SDivOp,
    URemOp,
    SRemOp,
    AShrOp,
    # SetLowBitsOp,
    # SetHighBitsOp,
    # TransIntegerType,
    # GetBitWidthOp,
)

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
]

custom_int_ops1: list[OpWithSignature] = [
    (NegOp, (INT_T,)),
    (AndOp, (INT_T, INT_T)),
    (OrOp, (INT_T, INT_T)),
    (XorOp, (INT_T, INT_T)),
    (AddOp, (INT_T, INT_T)),
    (SubOp, (INT_T, INT_T)),
    (SelectOp, (BOOL_T, INT_T, INT_T)),
    (UMinOp, (INT_T, INT_T)),
    (UMaxOp, (INT_T, INT_T)),
    (MulOp, (INT_T, INT_T)),
]

custom_int_ops2: list[OpWithSignature] = [
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
    (UDivOp, (INT_T, INT_T)),
    (SDivOp, (INT_T, INT_T)),
    (URemOp, (INT_T, INT_T)),
    (SRemOp, (INT_T, INT_T)),
    (MulOp, (INT_T, INT_T)),
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
    (AShrOp, (INT_T, BINT_T)),
    (ShlOp, (INT_T, BINT_T)),
    (UMinOp, (INT_T, INT_T)),
    (UMaxOp, (INT_T, INT_T)),
    (SMinOp, (INT_T, INT_T)),
    (SMaxOp, (INT_T, INT_T)),
    (UDivOp, (INT_T, INT_T)),
    (SDivOp, (INT_T, INT_T)),
    (URemOp, (INT_T, INT_T)),
    (SRemOp, (INT_T, INT_T)),
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
    custom_int_ops1 = list(set(custom_int_ops1 + full_bint_ops))
    custom_int_ops2 = list(set(custom_int_ops2 + full_bint_ops))


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


i1_prior_uniform: dict[OpWithSignature, int] = {k: 1 for k in full_i1_ops}

int_prior_uniform: dict[OpWithSignature, int] = {k: 1 for k in full_int_ops}

bint_prior_uniform: dict[OpWithSignature, int] = {k: 1 for k in full_bint_ops}

int_prior_uniform_stronger: dict[OpWithSignature, int] = {k: 10 for k in full_int_ops}

int_prior_bias: dict[OpWithSignature, int] = {
    (NegOp, (INT_T,)): 10,
    (AndOp, (INT_T, INT_T)): 10,
    (OrOp, (INT_T, INT_T)): 10,
    (XorOp, (INT_T, INT_T)): 10,
    (AddOp, (INT_T, INT_T)): 10,
    (SubOp, (INT_T, INT_T)): 10,
    (SelectOp, (BOOL_T, INT_T, INT_T)): 0,
    (LShrOp, (INT_T, BINT_T)): 0,
    (ShlOp, (INT_T, BINT_T)): 0,
    (UMinOp, (INT_T, INT_T)): 0,
    (UMaxOp, (INT_T, INT_T)): 0,
    (SMinOp, (INT_T, INT_T)): 0,
    (SMaxOp, (INT_T, INT_T)): 0,
    (MulOp, (INT_T, INT_T)): 0,
    (SetHighBitsOp, (INT_T, BINT_T)): 0,
    (SetLowBitsOp, (INT_T, BINT_T)): 0,
    (ClearHighBitsOp, (INT_T, BINT_T)): 0,
    (ClearLowBitsOp, (INT_T, BINT_T)): 0,
    (SetSignBitOp, (INT_T,)): 0,
    (ClearSignBitOp, (INT_T,)): 0,
}
