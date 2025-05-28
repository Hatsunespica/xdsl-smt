import argparse
import logging
import os.path
import sys
from typing import cast, Callable

from xdsl.context import Context
from xdsl.parser import Parser

from io import StringIO

from xdsl.utils.hints import isa

from xdsl_smt.cli.synth_one_iteration import synthesize_one_iteration
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
from xdsl_smt.utils.synthesizer_utils.log_utils import (
    setup_loggers,
    print_set_of_funcs_to_file,
)
from xdsl_smt.utils.synthesizer_utils.solution_set import (
    SolutionSet,
    UnsizedSolutionSet,
)
from xdsl_smt.utils.synthesizer_utils.synthesizer_context import SynthesizerContext
from xdsl_smt.utils.synthesizer_utils.random import Random


def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "transfer_functions", type=str, nargs="?", help="path to the transfer functions"
    )
    arg_parser.add_argument(
        "-random_file", type=str, nargs="?", help="the file includes all random numbers"
    )
    arg_parser.add_argument(
        "-random_seed", type=int, nargs="?", help="specify the random seed"
    )
    arg_parser.add_argument(
        "-program_length",
        type=int,
        nargs="?",
        help="Specify the maximal length of synthesized program. 40 by default.",
    )
    arg_parser.add_argument(
        "-total_rounds",
        type=int,
        nargs="?",
        help="Specify the number of rounds the synthesizer should run. 1000 by default.",
    )
    arg_parser.add_argument(
        "-num_programs",
        type=int,
        nargs="?",
        help="Specify the number of programs that runs at every round. 100 by default.",
    )
    arg_parser.add_argument(
        "-inv_temp",
        type=int,
        nargs="?",
        help="Inverse temperature \\beta for MCMC. The larger the value is, the lower the probability of accepting a program with a higher cost. 200 by default. "
        "E.g., MCMC has a 1/2 probability of accepting a program with a cost 1/beta higher. ",
    )
    arg_parser.add_argument(
        "-bitwidth",
        type=int,
        nargs="?",
        help="Specify the bitwidth of the evaluation engine",
    )
    arg_parser.add_argument(
        "-min_bitwidth",
        type=int,
        nargs="?",
        help="Specify the minimum bitwidth of the evaluation engine",
    )
    arg_parser.add_argument(
        "-solution_size",
        type=int,
        nargs="?",
        help="Specify the size of solution set",
    )
    arg_parser.add_argument(
        "-num_iters",
        type=int,
        nargs="?",
        help="Specify the number of iterations of the synthesizer needs to run",
    )
    arg_parser.add_argument(
        "-weighted_dsl",
        action="store_true",
        help="Learn weights for each DSL operations from previous for future iterations.",
    )
    arg_parser.add_argument(
        "-condition_length",
        type=int,
        nargs="?",
        help="Specify the maximal length of synthesized abduction. 6 by default.",
    )
    arg_parser.add_argument(
        "-num_abd_procs",
        type=int,
        nargs="?",
        help="Specify the number of mcmc processes that used for abduction. It should be less than num_programs. 0 by default (which means abduction is disabled).",
    )
    arg_parser.add_argument(
        "-num_random_tests",
        type=int,
        nargs="?",
        help="Specify the number of random test inputs at higher bitwidth. 0 by default",
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
TEST_SET_SIZE = 1000
CONCRETE_VAL_PER_TEST_CASE = 10
PROGRAM_LENGTH = 40
CONDITION_LENGTH = 6
NUM_PROGRAMS = 100
INIT_COST = 1
TOTAL_ROUNDS = 10000
INV_TEMP = 200
SOLUTION_SIZE = 8
NUM_ITERS = 100
NUM_ABD_PROCS = 0
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
VERBOSE = 1  # todo: make it a cmd line arg


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
    return func.sym_name.data.startswith("part_solution_")


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
    data_dir: str,
    transfer: list[FunctionWithCondition],
    base: list[FunctionWithCondition],
    domain: eval_engine.AbstractDomain,
    helper_funcs: list[str],
) -> list[EvalResult]:
    """
    This function is a helper of eval_transfer_func that prints the mlir func as cpp code
    When transfer is [], this function fill it into [top]
    """

    if not transfer:
        transfer = [ret_top_func]
    transfer_func_names: list[str] = []
    transfer_func_srcs: list[str] = []
    helper_func_srcs: list[str] = []
    assert get_top_func_op is not None
    for fc in transfer:
        caller_str, helper_strs = fc.get_function_str(print_to_cpp)
        transfer_func_names.append(fc.func_name)
        transfer_func_srcs.append(caller_str)
        helper_func_srcs += helper_strs

    base_func_names: list[str] = []
    base_func_srcs: list[str] = []
    for fc in base:
        caller_str, helper_strs = fc.get_function_str(print_to_cpp)
        base_func_names.append(fc.func_name)
        base_func_srcs.append(caller_str)
        helper_func_srcs += helper_strs

    return eval_engine.eval_transfer_func(
        data_dir,
        transfer_func_names,
        transfer_func_srcs,
        base_func_names,
        base_func_srcs,
        helper_funcs + helper_func_srcs,
        domain,
    )


def solution_set_eval_func(
    data_dir: str,
    domain: eval_engine.AbstractDomain,
    helper_funcs: list[str],
) -> Callable[
    [
        list[FunctionWithCondition],
        list[FunctionWithCondition],
    ],
    list[EvalResult],
]:
    """
    This function returns a simplified eval_func receiving transfer functions and base functions
    """
    return lambda transfer=list[FunctionWithCondition], base=list[
        FunctionWithCondition
    ]: (eval_transfer_func_helper(data_dir, transfer, base, domain, helper_funcs))


def tests_sampler_helper(
    domain: eval_engine.AbstractDomain,
    data_dir: str,
    samples: int,
    seed: int,
    helper_srcs: list[str],
    base: list[FunctionWithCondition],
):
    base_func_names: list[str] = []
    base_func_srcs: list[str] = []
    callee_srcs: list[str] = []
    for fc in base:
        caller_str, callee_strs = fc.get_function_str(print_to_cpp)
        base_func_names.append(fc.func_name)
        base_func_srcs.append(caller_str)
        callee_srcs += callee_strs

    eval_engine.reject_sampler(
        domain,
        data_dir,
        samples,
        seed,
        helper_srcs + callee_srcs,
        base_func_names,
        base_func_srcs,
    )


def solution_set_tests_sampler(
    domain: eval_engine.AbstractDomain,
    data_dir: str,
    helper_srcs: list[str],
) -> Callable[[list[FunctionWithCondition], int, int], None,]:
    return lambda base=list[
        FunctionWithCondition
    ], samples=int, seed=int: tests_sampler_helper(
        domain, data_dir, samples, seed, helper_srcs, base
    )


def save_solution(solution_module: ModuleOp, solution_str: str, outputs_folder: str):
    if not outputs_folder.endswith("/"):
        outputs_folder += "/"
    with open(outputs_folder + "solution.cpp", "w") as fout:
        fout.write(solution_str)
    with open(outputs_folder + "solution.mlir", "w") as fout:
        print(solution_module, file=fout)


def run(
    logger: logging.Logger,
    domain: eval_engine.AbstractDomain,
    num_programs: int,
    total_rounds: int,
    program_length: int,
    inv_temp: int,
    bitwidth: int,
    min_bitwidth: int,
    solution_size: int = SOLUTION_SIZE,
    num_iters: int = NUM_ITERS,
    condition_length: int = CONDITION_LENGTH,
    num_abd_procs: int = NUM_ABD_PROCS,
    num_random_tests: int | None = None,
    random_seed: int | None = None,
    random_number_file: str | None = None,
    transfer_functions: str | None = None,
    weighted_dsl: bool = False,
    outputs_folder: str = OUTPUTS_FOLDER,
) -> EvalResult:
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

    module = parse_file(ctx, transfer_functions)

    assert isinstance(module, ModuleOp)

    if not os.path.isdir(outputs_folder):
        os.mkdir(outputs_folder)

    logger.debug("Round_ID\tSound%\tUExact%\tUDis(Norm)\tCost")

    random = Random(random_seed)
    random_seed = random.randint(0, 1_000_000) if random_seed is None else random_seed
    if random_number_file is not None:
        random.read_from_file(random_number_file)

    samples = (random_seed, num_random_tests) if num_random_tests is not None else None

    if domain == eval_engine.AbstractDomain.KnownBits:
        EvalResult.get_max_dis = lambda x: x * 2
    elif domain == eval_engine.AbstractDomain.ConstantRange:
        EvalResult.get_max_dis = lambda x: (2**x - 1) * 2
    else:
        raise Exception("Unknown Maximum Distance of the domain")

    context = SynthesizerContext(random)
    context.set_cmp_flags([0, 6, 7])
    context.use_full_int_ops()
    context.use_basic_i1_ops()

    context_weighted = SynthesizerContext(random)
    context_weighted.set_cmp_flags([0, 6, 7])
    context_weighted.use_full_int_ops()
    context_weighted.use_basic_i1_ops()

    context_cond = SynthesizerContext(random)
    context_cond.set_cmp_flags([0, 6, 7])
    context_cond.use_full_int_ops()
    context_cond.use_full_i1_ops()

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

    if meet_func is None:
        solution_size = 1

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
    ]

    helper_funcs_cpp: list[str] = [print_concrete_function_to_cpp(crt_func)] + [
        print_to_cpp(func) for func in helper_funcs[1:]
    ]

    data_dir = eval_engine.setup_eval(
        domain, bitwidth, min_bitwidth, samples, "\n".join(helper_funcs_cpp)
    )

    base_bodys: dict[str, FuncOp] = {}
    base_conds: dict[str, FuncOp] = {}
    base_transfers: list[FunctionWithCondition] = []
    for func in module.ops:
        if isinstance(func, FuncOp) and is_base_function(func):
            func_name = func.sym_name.data
            if func_name.endswith("_body"):
                main_name = func_name[: -len("_body")]
                if main_name in base_conds:
                    body = func
                    cond = base_conds.pop(main_name)
                    body.attributes["number"] = StringAttr("init")
                    cond.attributes["number"] = StringAttr("init")
                    base_transfers.append(FunctionWithCondition(body, cond))
                else:
                    base_bodys[main_name] = func
            elif func_name.endswith("_cond"):
                main_name = func_name[: -len("_cond")]
                if main_name in base_bodys:
                    body = base_bodys.pop(main_name)
                    cond = func
                    body.attributes["number"] = StringAttr("init")
                    cond.attributes["number"] = StringAttr("init")
                    base_transfers.append(FunctionWithCondition(body, func))
                else:
                    base_conds[main_name] = func
    assert len(base_conds) == 0
    for _, func in base_bodys.items():
        func.attributes["number"] = StringAttr("init")
        base_transfers.append(FunctionWithCondition(func))

    solution_eval_func = solution_set_eval_func(
        data_dir,
        domain,
        helper_funcs_cpp,
    )
    solution_tests_sampler = solution_set_tests_sampler(
        domain,
        data_dir,
        helper_funcs_cpp,
    )
    solution_set: SolutionSet = UnsizedSolutionSet(
        base_transfers,
        print_to_cpp,
        solution_eval_func,
        solution_tests_sampler,
        logger,
        eliminate_dead_code,
    )

    # eval the initial solutions in the solution set

    init_cmp_res = solution_set.eval_improve([])
    logger.info(
        f"Initial Solution. Exact: {init_cmp_res[0].get_exact_prop() * 100:.4f}%   Dis:{init_cmp_res[0].get_base_dist()}"
    )
    print(
        f"init_solution\t{init_cmp_res[0].get_sound_prop() * 100:.4f}%\t{init_cmp_res[0].get_exact_prop() * 100:.4f}%"
    )

    current_prog_len = program_length
    current_total_rounds = min(500, total_rounds)
    current_num_abd_procs = min(0, num_abd_procs)
    for ith_iter in range(num_iters):
        # gradually increase the program length
        current_prog_len += (program_length - current_prog_len) // (
            num_iters - ith_iter
        )
        current_total_rounds += (total_rounds - current_total_rounds) // (
            num_iters - ith_iter
        )
        current_num_abd_procs += (num_abd_procs - current_num_abd_procs) // (
            num_iters - ith_iter
        )
        print(f"Iteration {ith_iter} starts...")
        if weighted_dsl:
            assert isinstance(solution_set, UnsizedSolutionSet)
            # if solution_set.solutions_size > 0:
            context_weighted.weighted = True
            solution_set.learn_weights(context_weighted)
        solution_set = synthesize_one_iteration(
            ith_iter,
            transfer_func,
            context,
            context_weighted,
            context_cond,
            random,
            solution_set,
            logger,
            crt_func,
            helper_funcs[1:],
            ctx,
            num_programs,
            current_prog_len,
            condition_length,
            current_num_abd_procs,
            current_total_rounds,
            solution_size,
            inv_temp,
            outputs_folder,
        )
        print_set_of_funcs_to_file(
            [f.to_str(eliminate_dead_code) for f in solution_set.solutions],
            ith_iter,
            outputs_folder,
        )

        final_cmp_res = solution_set.eval_improve([])
        logger.info(
            f"Iter {ith_iter} Finished. Exact: {final_cmp_res[0].get_exact_prop() * 100:.4f}%   Dis:{final_cmp_res[0].get_base_dist()}"
        )

        print(
            f"Iteration {ith_iter} finished. Size of the solution set: {solution_set.solutions_size}"
        )

        if solution_set.is_perfect:
            print("Found a perfect solution")
            break

        desired_unsolved_test_cases = 0
        new_test = solution_set.sample_unsolved_tests_up_to(
            desired_unsolved_test_cases, random.randint(0, 1_000_000)
        )
        logger.info(f"New test cases sampled: {new_test}")

    # Eval last solution:
    if not solution_set.has_solution():
        raise Exception("Found no solutions")
    solution_module, solution_str = solution_set.generate_solution_and_cpp()
    save_solution(solution_module, solution_str, outputs_folder)
    cmp_results: list[EvalResult] = eval_engine.eval_transfer_func(
        data_dir,
        ["solution"],
        [solution_str],
        [],
        [],
        helper_funcs_cpp + [print_to_cpp(meet_func)],
        domain,
    )

    solution_result = cmp_results[0]
    print(
        f"last_solution\t{solution_result.get_sound_prop() * 100:.2f}%\t{solution_result.get_exact_prop() * 100:.2f}%"
    )

    return solution_result


def main() -> None:
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    num_programs = NUM_PROGRAMS if args.num_programs is None else args.num_programs
    total_rounds = TOTAL_ROUNDS if args.total_rounds is None else args.total_rounds
    program_length = (
        PROGRAM_LENGTH if args.program_length is None else args.program_length
    )
    inv_temp = INV_TEMP if args.inv_temp is None else args.inv_temp
    bitwidth = SYNTH_WIDTH if args.bitwidth is None else args.bitwidth
    min_bitwidth = 1 if args.min_bitwidth is None else args.min_bitwidth
    solution_size = SOLUTION_SIZE if args.solution_size is None else args.solution_size
    num_iters = NUM_ITERS if args.num_iters is None else args.num_iters
    condition_length = (
        CONDITION_LENGTH if args.condition_length is None else args.condition_length
    )
    num_abd_procs = NUM_ABD_PROCS if args.num_abd_procs is None else args.num_abd_procs
    num_random_tests = None if args.num_random_tests is None else args.num_random_tests
    outputs_folder = (
        OUTPUTS_FOLDER if args.outputs_folder is None else args.outputs_folder
    )
    logger = setup_loggers(outputs_folder, VERBOSE)
    for k, v in vars(args).items():
        logger.info(f"{k}: {v}")

    run(
        logger=logger,
        domain=eval_engine.AbstractDomain[args.domain],
        num_programs=num_programs,
        total_rounds=total_rounds,
        program_length=program_length,
        inv_temp=inv_temp,
        bitwidth=bitwidth,
        min_bitwidth=min_bitwidth,
        solution_size=solution_size,
        num_iters=num_iters,
        condition_length=condition_length,
        num_abd_procs=num_abd_procs,
        num_random_tests=num_random_tests,
        random_seed=args.random_seed,
        random_number_file=args.random_file,
        transfer_functions=args.transfer_functions,
        weighted_dsl=args.weighted_dsl,
        outputs_folder=outputs_folder,
    )


if __name__ == "__main__":
    main()
