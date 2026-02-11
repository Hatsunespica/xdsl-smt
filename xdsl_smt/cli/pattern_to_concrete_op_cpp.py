#!/usr/bin/env python3

import argparse
from typing import cast
import sys

from xdsl.context import Context
from xdsl.ir import Operation
from xdsl.parser import Parser

from xdsl.dialects.arith import Arith
from xdsl.dialects.func import Func
from xdsl_smt.dialects.transfer import Transfer, AbstractValueType, TransIntegerType
from xdsl_smt.dialects.llvm_dialect import LLVM
from xdsl_smt.passes.transfer_lower import LowerToCpp, addDispatcher, addInductionOps
from xdsl.dialects.func import FuncOp, ReturnOp, CallOp
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
    IntegerAttr,
    StringAttr,
    Attribute,
    FunctionType,
    SSAValue,
    ArrayAttr
)


def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "input", type=str, help="input to the specification file"
    )
    arg_parser.add_argument(
        "output", type=str, nargs="?", help="input to the specification file", default="tmp.cpp"
    )
    arg_parser.add_argument(
        "-should_combine", type=str, nargs="+", help="the name of concrete pattern",default=["concrete_op"]
    )
    arg_parser.add_argument(
        "abstract_domain_length", nargs="?", type=int, help="The length of abstract type", default=2
    )


def parse_file(ctx: Context, file: str | None) -> Operation:
    if file is None:
        f = sys.stdin
        file = "<stdin>"
    else:
        f = open(file)

    parser = Parser(ctx, f.read(), file)
    module = parser.parse_op()
    return module


def is_transfer_function(func: FuncOp) -> bool:
    return "applied_to" in func.attributes

def checkFunctionValidity(func: FuncOp) -> bool:
    if len(func.function_type.inputs) != len(func.args):
        return False
    for func_type_arg, arg in zip(func.function_type.inputs, func.args):
        if func_type_arg != arg.type:
            return False
    return_op = func.body.block.last_op
    if not (return_op is not None and isinstance(return_op, ReturnOp)):
        return False
    return return_op.operands[0].type == func.function_type.outputs.data[0]


abstractType:AbstractValueType | None = None
TRANSFER_FUNCTION_DEFAULT_NAME = "patternBenchmarkImpl"

def initAbstractType(abstract_domain_length:int):
    global abstractType
    abstractType = AbstractValueType([TransIntegerType()]*abstract_domain_length)

def liftToAbstractType(ty:Attribute)->Attribute:
    if isinstance(ty, TransIntegerType):
       return abstractType
    return ty

def liftToAbstractOperation(op:Operation, valueMapping:dict[SSAValue, SSAValue]) -> Operation:
    if op.dialect_name() == "transfer":
        index = op.name.rfind(".")
        callee = op.name[index+1:] +"_solution"
        resultType = list(map(liftToAbstractType, op.result_types))
        newOp = CallOp(callee,op.operands,resultType)
    else:
        newOp = op.clone()
    for i, concrete_operand in enumerate(op.operands):
        newOp.operands[i] = valueMapping[concrete_operand]
    for concrete_res, res in zip(op.results, newOp.results):
        valueMapping[concrete_res] = res
    return newOp


def copyTransferFunctionBody(concrete_op:FuncOp, func:FuncOp):
    valueMapping:dict[SSAValue, SSAValue] = {}
    for concrete_arg, arg in zip(concrete_op.args, func.args):
        valueMapping[concrete_arg] = arg
    block = func.body.block
    for op in concrete_op.body.ops:
        newOp= liftToAbstractOperation(op, valueMapping)
        block.add_op(newOp)



def getTransferFunctionOp(concrete_op:FuncOp) -> FuncOp:
    funcType = concrete_op.function_type
    inputs = list(map(liftToAbstractType, funcType.inputs))
    outputs = list(map(liftToAbstractType, funcType.outputs))
    assert len(outputs) == 1 and isinstance(outputs[0], AbstractValueType)
    newFuncType = FunctionType.from_lists(inputs, outputs)
    func = FuncOp(TRANSFER_FUNCTION_DEFAULT_NAME, newFuncType)
    copyTransferFunctionBody(concrete_op, func)
    return func



def main() -> None:
    ctx = Context()
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    # Register all dialects
    ctx.load_dialect(Arith)
    ctx.load_dialect(Builtin)
    ctx.load_dialect(Func)
    ctx.load_dialect(Transfer)
    ctx.load_dialect(LLVM)

    # Parse the files
    module = parse_file(ctx, args.input)
    assert isinstance(module, ModuleOp)
    initAbstractType(args.abstract_domain_length)

    with open(args.output, "w") as fout:
        LowerToCpp.fout = fout
        for func in module.ops:
            if isinstance(func, FuncOp) and len(func.body.ops) > 1:
                func_name = func.sym_name.data
                if func_name in args.should_combine:
                    func.attributes["should_combine"] = ArrayAttr([StringAttr("llvm_pattern")])
                LowerToCpp(fout).apply(ctx, cast(ModuleOp, func))




if __name__ == "__main__":
    main()
