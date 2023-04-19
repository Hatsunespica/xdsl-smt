from typing import Any, TypeAlias, overload
from xdsl.dialects.builtin import IntegerType
from xdsl.ir import Attribute, Operation, SSAValue
from z3 import BitVec, BitVecSortRef, Bool, BoolSortRef, QuantifierRef, Sort
from dialects.smt_bitvector_dialect import BitVectorType

from dialects.smt_dialect import BoolType, ForallOp
from traits.smt_printer import SMTLibSort

name_counter: dict[str, int] = dict()
values_to_z3: dict[SSAValue, Any] = dict()
z3_to_values: dict[int, SSAValue] = dict()

Z3Expr: TypeAlias = Any


def to_z3_const(val: SSAValue) -> Z3Expr:
    '''
    Return the z3 constant associated to an SSAValue.
    If none exist, create one based on the SSAValue type.
    '''
    global values_to_z3
    global z3_to_values
    global name_counter
    global values_to_names

    # Check if we have already seen that value
    if val in values_to_z3:
        return values_to_z3[val]

    # Get the ssa value name
    base_name = val.name
    if base_name is None:
        base_name = 'tmp'

    # Use a numbering method to ensure distinct constants
    counter = name_counter.setdefault(base_name, 0)
    name = base_name + '@' + str(counter)
    name_counter[base_name] += counter

    # Create a z3 constant from an xDSL type
    const: Z3Expr
    if isinstance(val.typ, BitVectorType):
        const = BitVec(name, val.typ.width.data)
    elif isinstance(val.typ, BoolType):
        const = Bool(name)
    else:
        raise ValueError(f'Cannot convert value of type {val.typ.name} to z3')

    # Remember the association
    values_to_z3[val] = const
    z3_to_values[const.get_id()] = val
    return const


def to_z3_consts(*vals: SSAValue) -> tuple[Z3Expr, ...]:
    '''
    Convert each value to their associated z3 const.
    See `to_z3_const`.
    '''
    return tuple(to_z3_const(val) for val in vals)


def z3_sort_to_dialect(expr: Any) -> SMTLibSort:
    if isinstance(expr, BoolSortRef):
        return BoolType()
    if isinstance(expr, BitVecSortRef):
        return BitVectorType(expr.size())
    raise ValueError(f'Cannot convert {expr} to an SMTLib sort')


def z3_to_dialect(
        expr: Any,
        free_vars: list[Any] = []) -> tuple[list[Operation], SSAValue]:
    global z3_to_values

    if expr.get_id() in z3_to_values:
        return [], z3_to_values[expr.get_id()]
    raise NotImplementedError(f'Cannot convert {expr} to the SMT dialect')