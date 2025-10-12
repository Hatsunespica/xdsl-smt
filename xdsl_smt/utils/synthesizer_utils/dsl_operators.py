import json
from typing import Any
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

enable_bint = False
INT_T = "int"
BOOL_T = "bool"
BINT_T = "bint"
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


def merge_int_and_bint_ops(
    int_ops: list[OpWithSignature], bint_ops: list[OpWithSignature]
) -> list[OpWithSignature]:
    merged: list[OpWithSignature] = []
    for op in int_ops + bint_ops:
        # change the bint in signature into int, and then add it to the merged list
        merged.append((op[0], tuple(INT_T if t == BINT_T else t for t in op[1])))
    merged = list(set(merged))
    return merged


def read_ops_from_file(
    file_path: str,
) -> tuple[list[OpWithSignature], list[OpWithSignature], list[OpWithSignature]]:
    """
    Read i1_ops, int_ops, and bint_ops from a file.

    Args:
        file_path: Path to the file containing the operator definitions

    Returns:
        A tuple containing (i1_ops, int_ops, bint_ops) lists

    The file format should be a JSON file with the following structure:
    {
        "i1_ops": [
            {"op_name": "CmpOp", "signature": ["int", "int"]},
            {"op_name": "arith.AndIOp", "signature": ["bool", "bool"]},
            ...
        ],
        "int_ops": [
            {"op_name": "AddOp", "signature": ["int", "int"]},
            {"op_name": "NegOp", "signature": ["int"]},
            ...
        ],
        "bint_ops": [
            {"op_name": "AddOp", "signature": ["bint", "bint"]},
            ...
        ]
    }
    """
    # Create a mapping from operation names to operation classes
    op_name_to_class = {
        # Transfer dialect operations
        "NegOp": NegOp,
        "CmpOp": CmpOp,
        "AndOp": AndOp,
        "OrOp": OrOp,
        "XorOp": XorOp,
        "AddOp": AddOp,
        "SubOp": SubOp,
        "CountLOneOp": CountLOneOp,
        "CountLZeroOp": CountLZeroOp,
        "CountROneOp": CountROneOp,
        "CountRZeroOp": CountRZeroOp,
        "UMinOp": UMinOp,
        "UMaxOp": UMaxOp,
        "ShlOp": ShlOp,
        "LShrOp": LShrOp,
        "SelectOp": SelectOp,
        "MulOp": MulOp,
        "SMinOp": SMinOp,
        "SMaxOp": SMaxOp,
        "SetHighBitsOp": SetHighBitsOp,
        "SetLowBitsOp": SetLowBitsOp,
        "ClearHighBitsOp": ClearHighBitsOp,
        "ClearLowBitsOp": ClearLowBitsOp,
        "SetSignBitOp": SetSignBitOp,
        "ClearSignBitOp": ClearSignBitOp,
        "UDivOp": UDivOp,
        "SDivOp": SDivOp,
        "URemOp": URemOp,
        "SRemOp": SRemOp,
        "AShrOp": AShrOp,
        # Arith dialect operations
        "arith.AndIOp": arith.AndIOp,
        "arith.OrIOp": arith.OrIOp,
        "arith.XOrIOp": arith.XOrIOp,
    }

    with open(file_path, "r") as f:
        data = json.load(f)

    def parse_op_list(op_data: list[dict[str, Any]]) -> list[OpWithSignature]:
        """Parse a list of operation definitions into OpWithSignature tuples."""
        ops: list[OpWithSignature] = []
        for op_def in op_data:
            op_name = op_def["op_name"]
            signature = tuple(op_def["signature"])

            if op_name not in op_name_to_class:
                raise ValueError(f"Unknown operation: {op_name}")

            op_class = op_name_to_class[op_name]
            ops.append((op_class, signature))

        return ops

    i1_ops = parse_op_list(data.get("i1_ops", []))
    int_ops = parse_op_list(data.get("int_ops", []))
    bint_ops = parse_op_list(data.get("bint_ops", []))

    return i1_ops, int_ops, bint_ops
