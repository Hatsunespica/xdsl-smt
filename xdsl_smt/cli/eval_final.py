import argparse
import os.path
import glob
import sys
from typing import cast, Callable, Optional

from xdsl.context import Context
from xdsl.parser import Parser

from io import StringIO

from xdsl.utils.hints import isa

from xdsl_smt.passes.transfer_inline import FunctionCallInline
from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from ..dialects.smt_dialect import SMTDialect
from ..dialects.smt_bitvector_dialect import SMTBitVectorDialect
from xdsl_smt.dialects.transfer import TransIntegerType
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
import xdsl_smt.eval_engine.eval as eval_engine
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
    IntegerAttr,
    IntegerType,
    i1,
    FunctionType,
    ArrayAttr,
    StringAttr,
)
from xdsl.dialects.func import Func, FuncOp, ReturnOp, CallOp
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith, ConstantOp
from xdsl.dialects.comb import Comb
from xdsl.dialects.hw import HW
from ..passes.transfer_dead_code_elimination import TransferDeadCodeElimination

import xdsl.dialects.comb as comb
from xdsl.ir import Operation

from ..passes.transfer_lower import LowerToCpp

from xdsl_smt.semantics.comb_semantics import comb_semantics
from xdsl_smt.utils.synthesizer_utils.function_with_condition import (
    FunctionWithCondition,
)


def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "transfer_functions", type=str, nargs="?", help="path to the transfer functions"
    )
    arg_parser.add_argument(
        "solution_path", type=str, nargs="?", help="path to the solution"
    )
    arg_parser.add_argument(
        "-random_file", type=str, nargs="?", help="the file includes all random numbers"
    )
    arg_parser.add_argument(
        "-random_seed", type=int, nargs="?", help="specify the random seed"
    )
    arg_parser.add_argument(
        "-bitwidth",
        type=int,
        nargs="?",
        help="Specify the bitwidth of the evaluation engine",
    )
    arg_parser.add_argument(
        "-outputs_folder",
        type=str,
        nargs="?",
        help="Output folder for saving logs",
    )
    arg_parser.add_argument(
        "-domain",
        type=str,
        choices=[str(x) for x in eval_engine.AbstractDomain],
        required=True,
        help="Abstract Domain to evaluate",
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


def is_forward(func: FuncOp) -> bool:
    if "is_forward" in func.attributes:
        forward = func.attributes["is_forward"]
        assert isinstance(forward, IntegerAttr)
        return forward.value.data == 1
    return False


def get_concrete_function(
    concrete_op_name: str, width: int, extra: int | None
) -> FuncOp:
    # iterate all semantics and find corresponding comb operation

    result = None
    for k in comb_semantics.keys():
        if k.name == concrete_op_name:
            # generate a function with the only comb operation
            # for now, we only handle binary operations and mux
            intTy = IntegerType(width)
            transIntTy = TransIntegerType()
            func_name = "concrete_op"

            if concrete_op_name == "comb.mux":
                funcTy = FunctionType.from_lists([i1, intTy, intTy], [intTy])
                result = FuncOp(func_name, funcTy)
                combOp = k(*result.args)
            elif concrete_op_name == "comb.icmp":
                funcTy = FunctionType.from_lists([intTy, intTy], [i1])
                result = FuncOp(func_name, funcTy)
                assert extra is not None
                combOp = comb.ICmpOp(result.args[0], result.args[1], extra)
            elif concrete_op_name == "comb.concat":
                funcTy = FunctionType.from_lists(
                    [intTy, intTy], [IntegerType(width * 2)]
                )
                result = FuncOp(func_name, funcTy)
                combOp = comb.ConcatOp.from_int_values(result.args)
            else:
                funcTy = FunctionType.from_lists([transIntTy, transIntTy], [transIntTy])
                result = FuncOp(func_name, funcTy)
                if issubclass(k, comb.VariadicCombOperation):
                    combOp = k.create(operands=result.args, result_types=[intTy])
                else:
                    combOp = k(*result.args)

            assert isinstance(combOp, Operation)
            returnOp = ReturnOp(combOp.results[0])
            result.body.block.add_ops([combOp, returnOp])
    assert result is not None and (
        "Cannot find the concrete function for" + concrete_op_name
    )
    return result


def check_custom_concrete_func(concrete_func: FuncOp):
    op = concrete_func.body.block.first_op
    return not any(isinstance(op, ty) for ty in comb_semantics.keys())


def print_concrete_function_to_cpp(func: FuncOp) -> str:
    sio = StringIO()
    # [TODO] Xuanyu: Setting int_to_apint to True may cause error if concrete_op is customized.
    # For example, if the concrete_op uses transfer.select, the returned value should be i1 but will be turned into APInt.
    if check_custom_concrete_func(func):
        LowerToCpp(sio, False).apply(ctx, cast(ModuleOp, func))
    else:
        LowerToCpp(sio, True).apply(ctx, cast(ModuleOp, func))
    return sio.getvalue()


def get_default_op_constraint(concrete_func: FuncOp):
    cond_type = FunctionType.from_lists(concrete_func.function_type.inputs.data, [i1])
    func = FuncOp("op_constraint", cond_type)
    true_op: ConstantOp = ConstantOp(IntegerAttr.from_int_and_width(1, 1), i1)
    return_op = ReturnOp(true_op)
    func.body.block.add_ops([true_op, return_op])
    return func


def get_default_abs_op_constraint(abstract_func: FuncOp):
    cond_type = FunctionType.from_lists(abstract_func.function_type.inputs.data, [i1])
    func = FuncOp("abs_op_constraint", cond_type)
    true_op: ConstantOp = ConstantOp(IntegerAttr.from_int_and_width(1, 1), i1)
    return_op = ReturnOp(true_op)
    func.body.block.add_ops([true_op, return_op])
    return func


SYNTH_WIDTH = 4
INSTANCE_CONSTRAINT = "getInstanceConstraint"
DOMAIN_CONSTRAINT = "getConstraint"
OP_CONSTRAINT = "op_constraint"
ABS_OP_CONSTRAINT = "abs_op_constraint"
MEET_FUNC = "meet"
GET_TOP_FUNC = "getTop"
CONCRETE_OP_FUNC = "concrete_op"
get_top_func_op: FuncOp | None = None
ret_top_func: FunctionWithCondition
TMP_MODULE: list[ModuleOp] = []
ctx: Context

OUTPUTS_FOLDER = "outputs"


def eliminate_dead_code(func: FuncOp) -> FuncOp:
    """
    WARNING: this function modifies the func passed to it in place!
    """
    TransferDeadCodeElimination().apply(ctx, cast(ModuleOp, func))
    return func


def print_to_cpp(func: FuncOp) -> str:
    """
    This function eliminates dead code before lowering to cpp
    and it makes a copy of the function so it does not modify in place
    """
    sio = StringIO()
    region = func.body.clone()
    cloned_func = FuncOp(func.sym_name.data, func.function_type, region=region)
    TransferDeadCodeElimination().apply(ctx, cast(ModuleOp, cloned_func))
    LowerToCpp(sio).apply(ctx, cast(ModuleOp, cloned_func))

    return sio.getvalue()


def is_base_function(func: FuncOp) -> bool:
    # if "is_base" in func.attributes:
    #     base = func.attributes["is_base"]
    #     assert isinstance(base, IntegerAttr)
    #     return base.value.data == -1
    # return False
    return func.sym_name.data.startswith("partial_solution_")


def construct_top_func(transfer: FuncOp) -> FuncOp:
    func = FuncOp("top_transfer_function", transfer.function_type)
    func.attributes["applied_to"] = transfer.attributes["applied_to"]
    func.attributes["CPPCLASS"] = transfer.attributes["CPPCLASS"]
    func.attributes["is_forward"] = transfer.attributes["is_forward"]
    block = func.body.block
    args = func.args

    call_top_op = CallOp("getTop", [args[0]], func.function_type.outputs.data)
    assert len(call_top_op.results) == 1
    top_res = call_top_op.results[0]
    return_op = ReturnOp(top_res)
    block.add_ops([call_top_op, return_op])
    return func


def eval_transfer_func_helper(
    transfer: FuncOp,
    # base: list[FunctionWithCondition],
    domain: eval_engine.AbstractDomain,
    bitwidth: int,
    helper_funcs: list[str],
) -> list[EvalResult]:
    transfer_func_names: list[str] = [transfer.sym_name.data]
    transfer_func_srcs: list[str] = [print_to_cpp(transfer)]

    # base_func_names: list[str] = []
    # base_func_srcs: list[str] = []
    # for fc in base:
    #     caller_str, helper_strs = fc.get_function_str(print_to_cpp)
    #     base_func_names.append(fc.func_name)
    #     base_func_srcs.append(caller_str)
    #     helper_func_srcs += helper_strs

    return eval_engine.eval_transfer_func(
        transfer_func_names,
        transfer_func_srcs,
        [],  # base_func_names,
        [],  # base_func_srcs,
        helper_funcs,  # helper_funcs + helper_func_srcs,
        domain,
        bitwidth,
        None,
    )


def run(
    domain: eval_engine.AbstractDomain,
    bitwidth: int,
    input_path: str,
    solution_path: str,
):
    global ctx
    ctx = Context()
    ctx.load_dialect(Arith)
    ctx.load_dialect(Builtin)
    ctx.load_dialect(Func)
    ctx.load_dialect(SMTDialect)
    ctx.load_dialect(SMTBitVectorDialect)
    ctx.load_dialect(SMTUtilsDialect)
    ctx.load_dialect(Transfer)
    ctx.load_dialect(Index)
    ctx.load_dialect(Comb)
    ctx.load_dialect(HW)

    module = parse_file(ctx, input_path)
    sol_module = parse_file(ctx, solution_path)

    assert isinstance(module, ModuleOp)
    assert isinstance(sol_module, ModuleOp)

    if domain == eval_engine.AbstractDomain.KnownBits:
        EvalResult.get_max_dis = lambda x: x * 2
    elif domain == eval_engine.AbstractDomain.ConstantRange:
        EvalResult.get_max_dis = lambda x: (2**x - 1) * 2
    else:
        raise Exception("Unknown Maximum Distance of the domain")

    transfer_func = None

    func_name_to_func: dict[str, FuncOp] = {}
    for func in module.ops:
        if isinstance(func, FuncOp):
            func_name_to_func[func.sym_name.data] = func
    FunctionCallInline(False, func_name_to_func).apply(ctx, module)

    crt_func = func_name_to_func.get(CONCRETE_OP_FUNC, None)

    for func in module.ops:
        if (
            isinstance(func, FuncOp)
            and is_transfer_function(func)
            and not is_base_function(func)
        ):
            transfer_func = func
            if crt_func is None and "applied_to" in func.attributes:
                assert isa(
                    applied_to := func.attributes["applied_to"], ArrayAttr[StringAttr]
                )
                concrete_func_name = applied_to.data[0].data
                concrete_func = get_concrete_function(
                    concrete_func_name, SYNTH_WIDTH, None
                )
                crt_func = concrete_func
                break

    assert isinstance(
        transfer_func, FuncOp
    ), "No transfer function is found in input file"
    assert crt_func is not None, "Failed to get concrete function from input file"

    # Handle helper functions
    domain_constraint_func: FuncOp | None = func_name_to_func.get(
        DOMAIN_CONSTRAINT, None
    )
    instance_constraint_func: FuncOp | None = func_name_to_func.get(
        INSTANCE_CONSTRAINT, None
    )
    op_constraint_func: FuncOp | None = func_name_to_func.get(OP_CONSTRAINT, None)
    abs_op_constraint_func: FuncOp | None = func_name_to_func.get(
        ABS_OP_CONSTRAINT, None
    )
    meet_func: FuncOp | None = func_name_to_func.get(MEET_FUNC, None)
    get_top_func: FuncOp | None = func_name_to_func.get(GET_TOP_FUNC, None)
    global get_top_func_op
    get_top_func_op = get_top_func
    global ret_top_func
    ret_top_func = FunctionWithCondition(construct_top_func(transfer_func))
    ret_top_func.set_func_name("ret_top")

    if op_constraint_func is None:
        op_constraint_func = get_default_op_constraint(crt_func)
    if abs_op_constraint_func is None:
        abs_op_constraint_func = get_default_abs_op_constraint(transfer_func)
    assert instance_constraint_func is not None
    assert domain_constraint_func is not None
    assert meet_func is not None
    assert get_top_func is not None

    helper_funcs: list[FuncOp] = [
        crt_func,
        instance_constraint_func,
        domain_constraint_func,
        op_constraint_func,
        abs_op_constraint_func,
        get_top_func,
        meet_func,
    ]
    solution: Optional[FuncOp] = None
    for func in sol_module.ops:
        if isinstance(func, FuncOp):
            if func.sym_name.data == "solution":
                solution = func
            else:
                helper_funcs.append(func)

    helper_funcs_cpp: list[str] = [print_concrete_function_to_cpp(crt_func)] + [
        print_to_cpp(func) for func in helper_funcs[1:]
    ]
    assert solution is not None, "No solution function is found in solution file"
    init_cmp_res = eval_transfer_func_helper(
        solution, domain, bitwidth, helper_funcs_cpp
    )
    res = init_cmp_res[0]
    print(
        f"{res.per_bit[res.max_bit].exacts / res.per_bit[res.max_bit].all_cases*100:.4f}%"
    )
    return res


def main() -> None:
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    bitwidth = SYNTH_WIDTH if args.bitwidth is None else args.bitwidth
    outputs_folder = (
        OUTPUTS_FOLDER if args.outputs_folder is None else args.outputs_folder
    )

    # Check if transfer_functions is a directory
    if os.path.isdir(args.transfer_functions):
        input_files = glob.glob(os.path.join(args.transfer_functions, "*.mlir"))
    else:
        input_files = [args.transfer_functions]

    for input_path in input_files:
        base_name = os.path.splitext(os.path.basename(input_path))[0]
        solution_dir = os.path.join(args.solution_path, base_name)
        solution_path = os.path.join(solution_dir, "solution.mlir")
        # print(input_path)
        if not os.path.isdir(solution_dir):
            # print(f"Warning: solution directory does not exist: {solution_dir}")
            continue
        if not os.path.isfile(solution_path):
            print(f"Warning: solution file missing: {solution_path}")
            continue

        print(base_name, end=" ")

        run(
            eval_engine.AbstractDomain[args.domain],
            bitwidth=bitwidth,
            input_path=input_path,
            solution_path=solution_path,
        )


if __name__ == "__main__":
    main()
