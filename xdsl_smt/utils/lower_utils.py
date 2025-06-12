from typing import Callable
from ..dialects.transfer import (
    AbstractValueType,
    GetOp,
    MakeOp,
    NegOp,
    Constant,
    CmpOp,
    CountLOneOp,
    CountLZeroOp,
    CountROneOp,
    CountRZeroOp,
    SetHighBitsOp,
    SetLowBitsOp,
    SetSignBitOp,
    ClearSignBitOp,
    GetLowBitsOp,
    GetHighBitsOp,
    ClearLowBitsOp,
    ClearHighBitsOp,
    GetBitWidthOp,
    UMulOverflowOp,
    SMulOverflowOp,
    UAddOverflowOp,
    SAddOverflowOp,
    UShlOverflowOp,
    SShlOverflowOp,
    SMinOp,
    SMaxOp,
    UMinOp,
    UMaxOp,
    TransIntegerType,
    ShlOp,
    AShrOp,
    LShrOp,
    ExtractOp,
    ConcatOp,
    GetAllOnesOp,
    GetSignedMaxValueOp,
    GetSignedMinValueOp,
    SelectOp,
    NextLoopOp,
    ConstRangeForOp,
    RepeatOp,
    IntersectsOp,
    TupleType,
    AddPoisonOp,
    RemovePoisonOp,
    SDivOp,
    UDivOp,
    SRemOp,
    URemOp,
)
from xdsl.dialects.func import FuncOp, ReturnOp, CallOp
from functools import singledispatch
from xdsl.dialects.builtin import IntegerType, IndexType, IntegerAttr
from xdsl.ir import Attribute, Block, BlockArgument, Operation, SSAValue
import xdsl.dialects.arith as arith

operNameToCpp = {
    "transfer.and": "&",
    "arith.andi": "&",
    "transfer.add": "+",
    "arith.constant": "APInt",
    "arith.addi": "+",
    "transfer.or": "|",
    "arith.ori": "|",
    "transfer.xor": "^",
    "arith.xori": "^",
    "transfer.sub": "-",
    "arith.subi": "-",
    "transfer.neg": "~",
    "transfer.mul": "*",
    "transfer.udiv": ".udiv",
    "transfer.sdiv": ".sdiv",
    "transfer.urem": ".urem",
    "transfer.srem": ".srem",
    "transfer.umul_overflow": ".umul_ov",
    "transfer.smul_overflow": ".smul_ov",
    "transfer.uadd_overflow": ".uadd_ov",
    "transfer.sadd_overflow": ".sadd_ov",
    "transfer.ushl_overflow": ".ushl_ov",
    "transfer.sshl_overflow": ".sshl_ov",
    "transfer.get_bit_width": ".getBitWidth",
    "transfer.countl_zero": ".countl_zero",
    "transfer.countr_zero": ".countr_zero",
    "transfer.countl_one": ".countl_one",
    "transfer.countr_one": ".countr_one",
    "transfer.get_high_bits": ".getHiBits",
    "transfer.get_low_bits": ".getLoBits",
    "transfer.set_high_bits": ".setHighBits",
    "transfer.set_low_bits": ".setLowBits",
    "transfer.clear_high_bits": ".clearHighBits",
    "transfer.clear_low_bits": ".clearLowBits",
    "transfer.set_sign_bit": ".setSignBit",
    "transfer.clear_sign_bit": ".clearSignBit",
    "transfer.intersects": ".intersects",
    "transfer.cmp": [
        ".eq",
        ".ne",
        ".slt",
        ".sle",
        ".sgt",
        ".sge",
        ".ult",
        ".ule",
        ".ugt",
        ".uge",
    ],
    # "transfer.fromArith": "APInt",
    "transfer.make": "{{{0}}}",
    "transfer.get": "[{0}]",
    "transfer.shl": ".shl",
    "transfer.ashr": ".ashr",
    "transfer.lshr": ".lshr",
    "transfer.concat": ".concat",
    "transfer.extract": ".extractBits",
    "transfer.umin": [".ule", "?", ":"],
    "transfer.smin": [".sle", "?", ":"],
    "transfer.umax": [".ugt", "?", ":"],
    "transfer.smax": [".sgt", "?", ":"],
    "func.return": "return",
    "transfer.constant": "APInt",
    "arith.select": ["?", ":"],
    "arith.cmpi": ["==", "!=", "<", "<=", ">", ">="],
    "transfer.get_all_ones": "APInt::getAllOnes",
    "transfer.get_signed_max_value": "APInt::getSignedMaxValue",
    "transfer.get_signed_min_value": "APInt::getSignedMinValue",
    "transfer.select": ["?", ":"],
    "transfer.reverse_bits": ".reverseBits",
    "transfer.add_poison": " ",
    "transfer.remove_poison": " ",
    "comb.add": "+",
    "comb.sub": "-",
    "comb.mul": "*",
    "comb.and": "&",
    "comb.or": "|",
    "comb.xor": "^",
    "comb.divs": ".sdiv",
    "comb.divu": ".udiv",
    "comb.mods": ".srem",
    "comb.modu": ".urem",
    "comb.mux": ["?", ":"],
    "comb.shrs": ".ashr",
    "comb.shru": ".lshr",
    "comb.shl": ".shl",
    "comb.extract": ".extractBits",
    "comb.concat": ".concat",
}
# transfer.constRangeLoop and NextLoop are controller operations, should be handle specially


# operNameToConstraint is used for storing operation constraints used in synthesizing dataflow operations
# It has shape operNname -> (condition, action). If the condition satisfies, the operation doesn't change
# while it creates an else branch and performs the action
# The action should be a string with parameters (result values, *new_args)
SHIFTING_ACTION = (
    "{1}.uge(0) && {1}.ule({1}.getBitWidth())",
    "{0} = APInt({1}.getBitWidth(), 0)",
)

SET_BITS_ACTION = (
    "{1}.uge(0) && {0}.ule({0}.getBitWidth()) && {1}.ule({1}.getBitWidth())",
    "{0} = APInt({1}.getBitWidth(), 0)",
)

CLEAR_BITS_ACTION = (
    "{0}.ule({0}.getBitWidth())",
    "{0} = APInt({0}.getBitWidth(), 0)",
)

DIV_ACTION = (
    "{1}!=(0)",
    "{0} = APInt({1}.getBitWidth(), 0)",
)

# TODO new stuff
# SHIFTING_ACTION = "{1}.ugt({1}.getBitWidth())", "{0} = APInt({1}.getBitWidth(), 0)"
# REM_ACTION = "{1}==0", "{0}={1}"
# DIV_ACTION = "{1}==0", "{0}=APInt({1}.getBitWidth(), -1)"
# SDIV_ACTION = (
#     "{1}==-1 && {0}.isMinSignedValue()",
#     "{0}=APInt::getSignedMinValue({1}.getBitWidth())",
# )
#
# # TODO see what `xdsl_smt/semantics/transfer_semantics.py` is doing and match it
# # TODO wrong bc it's backwards now
# SET_BITS_ACTION = (
#     "{1}.uge(0) && {0}.ule({0}.getBitWidth()) && {1}.ule({1}.getBitWidth())",
#     "{0} = APInt({1}.getBitWidth(), 0)",
# )
#
# # TODO see what `xdsl_smt/semantics/transfer_semantics.py` is doing and match it
# # TODO wrong bc it's backwards now
# CLEAR_BITS_ACTION = (
#     "{0}.ule({0}.getBitWidth())",
#     "{0} = APInt({0}.getBitWidth(), 0)",
# )

operationToConstraint: dict[type[Operation], tuple[str, str]] = {
    SetLowBitsOp: SET_BITS_ACTION,
    SetHighBitsOp: SET_BITS_ACTION,
    ClearLowBitsOp: CLEAR_BITS_ACTION,
    ClearHighBitsOp: CLEAR_BITS_ACTION,
    ShlOp: SHIFTING_ACTION,
    AShrOp: SHIFTING_ACTION,
    LShrOp: SHIFTING_ACTION,
    UDivOp: DIV_ACTION,
    SDivOp: DIV_ACTION,
    URemOp: DIV_ACTION,
    SRemOp: DIV_ACTION,
}

unsignedReturnedType = {
    CountLOneOp,
    CountLZeroOp,
    CountROneOp,
    CountRZeroOp,
    GetBitWidthOp,
}

ends = ";\n"
indent = "\t"
equals = "="
int_to_apint = False
use_custom_vec = True


def set_int_to_apint(to_apint: bool) -> None:
    global int_to_apint
    int_to_apint = to_apint


def set_use_custom_vec(custom_vec: bool) -> None:
    global use_custom_vec
    use_custom_vec = custom_vec


def get_ret_val(op: Operation) -> str:
    ret_val = op.results[0].name_hint
    assert ret_val
    return ret_val


def get_op_names(op: Operation) -> list[str]:
    return [oper.name_hint for oper in op.operands if oper.name_hint]


def get_operand(op: Operation, idx: int) -> str:
    name = op.operands[idx].name_hint
    assert name
    return name


def get_op_str(op: Operation) -> str:
    op_name = operNameToCpp[op.name]
    assert isinstance(op_name, str)
    return op_name


def lowerType(typ: Attribute, specialOp: Operation | Block | None = None) -> str:
    if specialOp is not None:
        for op in unsignedReturnedType:
            if isinstance(specialOp, op):
                return "unsigned"
    if isinstance(typ, TransIntegerType):
        return "APInt"
    elif isinstance(typ, AbstractValueType) or isinstance(typ, TupleType):
        fields = typ.get_fields()
        typeName = lowerType(fields[0])
        for i in range(1, len(fields)):
            assert lowerType(fields[i]) == typeName
        if use_custom_vec:
            return "Vec<" + str(len(fields)) + ">"
        return "std::vector<" + typeName + ">"
    elif isinstance(typ, IntegerType):
        return "int" if not int_to_apint else "APInt"
    elif isinstance(typ, IndexType):
        return "int"
    assert False and "unsupported type"


CPP_CLASS_KEY = "CPPCLASS"
INDUCTION_KEY = "induction"
OPERATION_NO = "operationNo"


def lowerInductionOps(inductionOp: list[FuncOp]):
    if len(inductionOp) > 0:
        functionSignature = """
{returnedType} {funcName}(ArrayRef<{returnedType}> operands){{
    {returnedType} result={funcName}(operands[0], operands[1]);
    for(int i=2;i<operands.size();++i){{
        result={funcName}(result, operands[i]);
    }}
    return result;
}}

"""
        result = ""
        for func in inductionOp:
            returnedType = func.function_type.outputs.data[0]
            funcName = func.sym_name.data
            returnedType = lowerType(returnedType)
            result += functionSignature.format(
                returnedType=returnedType, funcName=funcName
            )
        return result


def lowerDispatcher(needDispatch: list[FuncOp], is_forward: bool):
    if len(needDispatch) > 0:
        returnedType = needDispatch[0].function_type.outputs.data[0]
        for func in needDispatch:
            if func.function_type.outputs.data[0] != returnedType:
                print(func)
                print(func.function_type.outputs.data[0])
                assert (
                    "we assume all transfer functions have the same returned type"
                    and False
                )
        returnedType = lowerType(returnedType)
        funcName = "naiveDispatcher"
        # we assume all operands have the same type as expr
        # User should tell the generator all operands
        if is_forward:
            expr = "(Operation* op, std::vector<std::vector<llvm::APInt>> operands)"
        else:
            expr = "(Operation* op, std::vector<std::vector<llvm::APInt>> operands, unsigned operationNo)"
        functionSignature = (
            "std::optional<" + returnedType + "> " + funcName + expr + "{{\n{0}}}\n\n"
        )
        indent = "\t"
        dyn_cast = (
            indent
            + "if(auto castedOp=dyn_cast<{0}>(op);castedOp&&{1}){{\n{2}"
            + indent
            + "}}\n"
        )
        return_inst = indent + indent + "return {0}({1});\n"

        def handleOneTransferFunction(func: FuncOp, operationNo: int) -> str:
            blockStr = ""
            for cppClass in func.attributes[CPP_CLASS_KEY]: # type: ignore
                argStr = ""
                if INDUCTION_KEY in func.attributes:
                    argStr = "operands"
                else:
                    if len(func.args) > 0:
                        argStr = "operands[0]"
                    for i in range(1, len(func.args)):
                        argStr += ", operands[" + str(i) + "]"
                ifBody = return_inst.format(func.sym_name.data, argStr)
                if operationNo == -1:
                    operationNoStr = "true"
                else:
                    operationNoStr = "operationNo == " + str(operationNo)
                blockStr += dyn_cast.format(cppClass.data, operationNoStr, ifBody) # type: ignore
            return blockStr

        funcBody = ""
        for func in needDispatch:
            if is_forward:
                funcBody += handleOneTransferFunction(func, -1)
            else:
                operationNo = func.attributes[OPERATION_NO]
                assert isinstance(operationNo, IntegerAttr)
                funcBody += handleOneTransferFunction(func, operationNo.value.data)
        funcBody += indent + "return {};\n"
        return functionSignature.format(funcBody)


def isFunctionCall(opName: str) -> bool:
    return opName[0] == "."


def lowerToNonClassMethod(op: Operation) -> str:
    ret_type = lowerType(op.results[0].type, op)
    ret_val = get_ret_val(op)
    expr = "("
    if len(op.operands) > 0:
        expr += get_operand(op, 0)
    for i in range(1, len(op.operands)):
        expr += "," + get_operand(op, i)
    expr += ")"

    return indent + ret_type + " " + ret_val + equals + get_op_str(op) + expr + ends


def lowerToClassMethod(
    op: Operation,
    castOperand: Callable[[SSAValue | str], str] | None = None,
    castResult: Callable[[Operation], str] | None = None,
) -> str:
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    if castResult is not None:
        returnedValue += "_autocast"
    expr = get_operand(op, 0) + get_op_str(op) + "("

    if castOperand is not None:
        operands = [castOperand(operand) for operand in op.operands]
    else:
        operands = get_op_names(op)

    if len(operands) > 1:
        expr += operands[1]
    for i in range(2, len(operands)):
        expr += "," + operands[i]

    expr += ")"

    if type(op) in operationToConstraint:
        constraint, replacement = operationToConstraint[type(op)]
        original_operand_names = [operand.name_hint for operand in op.operands]
        condition = constraint.format(*original_operand_names)
        result = indent + returnedType + " " + returnedValue + ends
        true_branch = indent + "\t" + returnedValue + equals + expr + ends

        action = replacement.format(returnedValue, *original_operand_names)

        false_branch = indent + "\t" + action + ends

        if_branch = (
            indent
            + "if({condition}){{\n{true_branch}"
            + indent
            + "}}else{{\n{false_branch}"
            + indent
            + "}}\n"
        )
        result = result + if_branch.format(
            condition=condition, true_branch=true_branch, false_branch=false_branch
        )

    else:
        result = indent + returnedType + " " + returnedValue + equals + expr + ends
    if castResult is not None:
        return result + castResult(op)

    return result


@singledispatch
def lowerOperation(op: Operation) -> str:
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    operandsName = get_op_names(op)
    op_str = get_op_str(op)

    if isFunctionCall(op_str):
        expr = operandsName[0] + op_str + "("
        if len(operandsName) > 1:
            expr += operandsName[1]
        for i in range(2, len(operandsName)):
            expr += "," + operandsName[i]
        expr += ")"
    else:
        expr = operandsName[0] + op_str + operandsName[1]

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: CmpOp):
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    operandsName = get_op_names(op)
    predicate = op.predicate.value.data
    operName = operNameToCpp[op.name][predicate]
    expr = operandsName[0] + operName + "("
    if len(operandsName) > 1:
        expr += operandsName[1]
    for i in range(2, len(operandsName)):
        expr += "," + operandsName[i]
    expr += ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: arith.CmpiOp):
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    operandsName = get_op_names(op)
    assert len(operandsName) == 2
    predicate = op.predicate.value.data
    operName = operNameToCpp[op.name][predicate]
    expr = "(" + operandsName[0] + operName + operandsName[1] + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: arith.SelectOp):
    returnedType = lowerType(op.operands[1].type, op)
    returnedValue = get_ret_val(op)
    operandsName = get_op_names(op)
    operator = operNameToCpp[op.name]
    expr = ""
    for i in range(len(operandsName)):
        expr += operandsName[i] + " "
        if i < len(operator):
            expr += operator[i] + " "

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: SelectOp):
    returnedType = lowerType(op.operands[1].type, op)
    returnedValue = get_ret_val(op)
    operandsName = get_op_names(op)
    operator = operNameToCpp[op.name]
    expr = ""
    for i in range(len(operandsName)):
        expr += operandsName[i] + " "
        if i < len(operator):
            expr += operator[i] + " "

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: GetOp) -> str:
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    index = op.attributes["index"].value.data # type: ignore

    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + equals
        + get_operand(op, 0)
        + get_op_str(op).format(index) # type: ignore
        + ends
    )


@lowerOperation.register
def _(op: MakeOp) -> str:
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    expr = ""
    if len(op.operands) > 0:
        expr += get_operand(op, 0)
    for i in range(1, len(op.operands)):
        expr += "," + get_operand(op, i)

    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + equals
        + returnedType
        + get_op_str(op).format(expr)
        + ends
    )


def trivial_overflow_predicate(op: Operation) -> str:
    returnedValue = get_ret_val(op)
    varDecls = "bool " + returnedValue + ends
    expr = get_operand(op, 0) + get_op_str(op) + "("
    expr += get_operand(op, 1) + "," + returnedValue + ")"
    result = varDecls + "\t" + expr + ends
    return indent + result


@lowerOperation.register
def _(op: UMulOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: SMulOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: UAddOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: SAddOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: SShlOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: UShlOverflowOp):
    return trivial_overflow_predicate(op)


@lowerOperation.register
def _(op: NegOp) -> str:
    ret_type = lowerType(op.results[0].type)
    ret_val = get_ret_val(op)
    op_str = get_op_str(op)
    operand = get_operand(op, 0)

    return indent + ret_type + " " + ret_val + equals + op_str + operand + ends


@lowerOperation.register
def _(op: ReturnOp) -> str:
    opName = get_op_str(op) + " "
    operand = op.arguments[0].name_hint
    assert operand

    return indent + opName + operand + ends


@lowerOperation.register
def _(op: arith.ConstantOp):
    value = op.value.value.data  # type: ignore
    assert isinstance(value, int) or isinstance(value, float)
    assert isinstance(op.results[0].type, IntegerType)
    size = op.results[0].type.width.data
    max_val_plus_one = 1 << size
    returnedType = "int"
    if value >= (1 << 31):
        assert False and "arith constant overflow maximal int"
    returnedValue = get_ret_val(op)
    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + " = "
        + str((value + max_val_plus_one) % max_val_plus_one)
        + ends
    )


@lowerOperation.register
def _(op: Constant):
    value = op.value.value.data
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + "("
        + get_operand(op, 0)
        + ".getBitWidth(),"
        + str(value)
        + ")"
        + ends
    )


@lowerOperation.register
def _(op: GetAllOnesOp):
    ret_type = lowerType(op.results[0].type)
    ret_val = get_ret_val(op)
    op_name = get_op_str(op)

    return (
        indent
        + ret_type
        + " "
        + ret_val
        + " = "
        + op_name
        + "("
        + get_operand(op, 0)
        + ".getBitWidth()"
        + ")"
        + ends
    )


@lowerOperation.register
def _(op: GetSignedMaxValueOp):
    ret_type = lowerType(op.results[0].type)
    ret_val = get_ret_val(op)
    op_name = get_op_str(op)

    return (
        indent
        + ret_type
        + " "
        + ret_val
        + " = "
        + op_name
        + "("
        + get_operand(op, 0)
        + ".getBitWidth()"
        + ")"
        + ends
    )


@lowerOperation.register
def _(op: GetSignedMinValueOp):
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    op_name = get_op_str(op)

    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + " = "
        + op_name
        + "("
        + get_operand(op, 0)
        + ".getBitWidth()"
        + ")"
        + ends
    )


@lowerOperation.register
def _(op: CallOp):
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    callee = op.callee.string_value() + "("
    operandsName = get_op_names(op)
    expr = ""
    if len(operandsName) > 0:
        expr += operandsName[0]
    for i in range(1, len(operandsName)):
        expr += "," + operandsName[i]
    expr += ")"
    return indent + returnedType + " " + returnedValue + "=" + callee + expr + ends


@lowerOperation.register
def _(op: FuncOp):
    def lowerArgs(arg: BlockArgument) -> str:
        assert arg.name_hint
        return lowerType(arg.type) + " " + arg.name_hint

    returnedType = lowerType(op.function_type.outputs.data[0])
    funcName = op.sym_name.data
    expr = "("
    if len(op.args) > 0:
        expr += lowerArgs(op.args[0])
    for i in range(1, len(op.args)):
        expr += "," + lowerArgs(op.args[i])
    expr += ")"

    return returnedType + " " + funcName + expr + "{\n"


def castToAPIntFromUnsigned(op: Operation) -> str:
    returnedValue = get_ret_val(op)
    lastReturn = returnedValue + "_autocast"
    apInt = None
    for operand in op.operands:
        if isinstance(operand.type, TransIntegerType):
            apInt = operand.name_hint
            break
    returnedType = "APInt"
    assert apInt

    return (
        indent
        + returnedType
        + " "
        + returnedValue
        + "("
        + apInt
        + ".getBitWidth(),"
        + lastReturn
        + ")"
        + ends
    )


@lowerOperation.register
def _(op: SDivOp):
    return lowerToClassMethod(op, None, None)


@lowerOperation.register
def _(op: UDivOp):
    return lowerToClassMethod(op, None, None)


@lowerOperation.register
def _(op: SRemOp):
    return lowerToClassMethod(op, None, None)


@lowerOperation.register
def _(op: URemOp):
    return lowerToClassMethod(op, None, None)


@lowerOperation.register
def _(op: IntersectsOp):
    return lowerToClassMethod(op, None, None)


@lowerOperation.register
def _(op: CountLOneOp):
    return lowerToClassMethod(op, None, castToAPIntFromUnsigned)


@lowerOperation.register
def _(op: CountLZeroOp):
    return lowerToClassMethod(op, None, castToAPIntFromUnsigned)


@lowerOperation.register
def _(op: CountROneOp):
    return lowerToClassMethod(op, None, castToAPIntFromUnsigned)


@lowerOperation.register
def _(op: CountRZeroOp):
    return lowerToClassMethod(op, None, castToAPIntFromUnsigned)


def castToUnisgnedFromAPInt(operand: SSAValue | str) -> str:
    if isinstance(operand, str):
        return "(" + operand + ").getZExtValue()"
    elif isinstance(operand.type, TransIntegerType):
        return f"{operand.name_hint}.getZExtValue()"

    return str(operand.name_hint)


@lowerOperation.register
def _(op: SetHighBitsOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = get_operand(op, 1) + ".getZExtValue()"
    expr = expr + operands + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: SetLowBitsOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = get_operand(op, 1) + ".getZExtValue()"
    expr = expr + operands + ")"
    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: ClearHighBitsOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = get_operand(op, 1) + ".getZExtValue()"
    expr = expr + operands + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: ClearLowBitsOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = get_operand(op, 1) + ".getZExtValue()"
    expr = expr + operands + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: SetSignBitOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = ""
    expr = expr + operands + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: ClearSignBitOp):
    returnedType = lowerType(op.results[0].type, op)
    returnedValue = get_ret_val(op)
    equals = "=" + get_operand(op, 0) + ends + "\t"
    expr = returnedValue + get_op_str(op) + "("
    operands = ""
    expr = expr + operands + ")"

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: GetLowBitsOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: GetHighBitsOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: GetBitWidthOp):
    return lowerToClassMethod(op, None, castToAPIntFromUnsigned)


# op1 < op2? op1: op2
@lowerOperation.register
def _(op: SMaxOp):
    returnedType = lowerType(op.operands[0].type, op)
    returnedValue = get_ret_val(op)
    operands = get_op_names(op)
    operator = operNameToCpp[op.name]

    expr = (
        operands[0]
        + operator[0]
        + "("
        + operands[1]
        + ")"
        + operator[1]
        + operands[0]
        + operator[2]
        + operands[1]
    )

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: SMinOp):
    returnedType = lowerType(op.operands[0].type, op)
    returnedValue = get_ret_val(op)
    operands = get_op_names(op)
    operator = operNameToCpp[op.name]

    expr = (
        operands[0]
        + operator[0]
        + "("
        + operands[1]
        + ")"
        + operator[1]
        + operands[0]
        + operator[2]
        + operands[1]
    )

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: UMaxOp):
    returnedType = lowerType(op.operands[0].type, op)
    returnedValue = get_ret_val(op)
    operands = get_op_names(op)
    operator = operNameToCpp[op.name]

    expr = (
        operands[0]
        + operator[0]
        + "("
        + operands[1]
        + ")"
        + operator[1]
        + operands[0]
        + operator[2]
        + operands[1]
    )

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: UMinOp):
    returnedType = lowerType(op.operands[0].type, op)
    returnedValue = get_ret_val(op)
    operands = get_op_names(op)
    operator = operNameToCpp[op.name]

    expr = (
        operands[0]
        + operator[0]
        + "("
        + operands[1]
        + ")"
        + operator[1]
        + operands[0]
        + operator[2]
        + operands[1]
    )

    return indent + returnedType + " " + returnedValue + equals + expr + ends


@lowerOperation.register
def _(op: ShlOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: AShrOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: LShrOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: ExtractOp):
    return lowerToClassMethod(op, castToUnisgnedFromAPInt)


@lowerOperation.register
def _(op: ConcatOp):
    return lowerToClassMethod(op)


@lowerOperation.register
def _(op: ConstRangeForOp):
    loopBody = op.body.block
    lowerBound = op.lb.name_hint
    upperBound = op.ub.name_hint
    step = op.step.name_hint

    indvar, *block_iter_args = loopBody.args
    iter_args = op.iter_args

    global indent
    loopBefore = ""
    for i, blk_arg in enumerate(block_iter_args):
        iter_type = lowerType(iter_args[i].type, iter_args[i].owner)
        iter_name = blk_arg.name_hint
        iter_arg = iter_args[i].name_hint
        assert iter_name
        assert iter_arg

        loopBefore += indent + iter_type + " " + iter_name + " = " + iter_arg + ends

    loopFor = indent + "for(APInt {0} = {1}; {0}.ule({2}); {0}+={3}){{\n".format(
        indvar.name_hint, lowerBound, upperBound, step
    )
    indent += "\t"
    """
    mainLoop=""
    for loopOp in loopBody.ops:
        mainLoop+=(indent  + indent+ lowerOperation(loopOp))
    endLoopFor=indent+"}\n"
    """
    return loopBefore + loopFor


@lowerOperation.register
def _(op: NextLoopOp) -> str:
    loopBlock = op.parent_block()
    assert loopBlock
    _, *block_iter_args = loopBlock.args
    global indent
    assignments = ""
    for i, arg in enumerate(op.operands):
        block_arg = block_iter_args[i].name_hint
        arg_name = arg.name_hint
        assert block_arg
        assert arg_name

        assignments += indent + block_arg + " = " + arg_name + ends

    indent = indent[:-1]
    endLoopFor = indent + "}\n"
    loopOp = loopBlock.parent_op()
    assert loopOp

    for i, res in enumerate(loopOp.results):
        ty = lowerType(res.type, loopOp)
        res_name = res.name_hint
        block_arg = block_iter_args[i].name_hint
        assert res_name
        assert block_arg

        endLoopFor += indent + ty + " " + res_name + " = " + block_arg + ends

    return assignments + endLoopFor


@lowerOperation.register
def _(op: RepeatOp):
    returnedType = lowerType(op.operands[0].type, op)
    returnedValue = get_ret_val(op)
    arg0_name = get_operand(op, 0)
    count = get_operand(op, 1)
    initExpr = indent + returnedType + " " + returnedValue + " = " + arg0_name + ends
    forHead = (
        indent
        + "for(APInt i("
        + count
        + ".getBitWidth(),1);i.ult("
        + count
        + ");++i){\n"
    )
    forBody = (
        indent
        + "\t"
        + returnedValue
        + " = "
        + returnedValue
        + ".concat("
        + arg0_name
        + ")"
        + ends
    )
    forEnd = indent + "}\n"
    return initExpr + forHead + forBody + forEnd


@lowerOperation.register
def _(op: AddPoisonOp):
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    operand = get_operand(op, 0)

    return indent + returnedType + " " + returnedValue + " = " + operand + ends


@lowerOperation.register
def _(op: RemovePoisonOp) -> str:
    returnedType = lowerType(op.results[0].type)
    returnedValue = get_ret_val(op)
    operand = get_operand(op, 0)

    return indent + returnedType + " " + returnedValue + " = " + operand + ends
