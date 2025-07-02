import logging
from typing import cast, Callable
from io import StringIO
from dataclasses import dataclass
from pathlib import Path

from xdsl.context import Context
from xdsl.parser import Parser
from xdsl.utils.hints import isa

from xdsl_smt.cli.synth_one_iteration import synthesize_one_iteration
from xdsl_smt.passes.transfer_inline import FunctionCallInline
from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from ..dialects.smt_dialect import SMTDialect
from ..dialects.smt_bitvector_dialect import SMTBitVectorDialect
from xdsl_smt.dialects.transfer import TransIntegerType, AbstractValueType
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl_smt.eval_engine.eval import (
    AbstractDomain,
    setup_eval,
    eval_transfer_func,
    reject_sampler,
)
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
from xdsl.dialects.arith import Arith
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
from xdsl_smt.cli.arg_parser import register_arguments

# TODO this should be made local
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


def parse_file(file: Path) -> ModuleOp:
    with open(file, "r") as f:
        module = Parser(ctx, f.read(), file.name).parse_op()

    assert isinstance(module, ModuleOp)

    return module


def is_forward(func: FuncOp) -> bool:
    if "is_forward" in func.attributes:
        forward = func.attributes["is_forward"]
        assert isinstance(forward, IntegerAttr)
        return forward.value.data == 1
    return False


def get_concrete_function(concrete_op_name: str, extra: int | None) -> FuncOp:
    # iterate all semantics and find corresponding comb operation

    result = None
    for k in comb_semantics.keys():
        if k.name == concrete_op_name:
            # generate a function with the only comb operation
            # for now, we only handle binary operations and mux
            width = 4
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
        f"Cannot find the concrete function for {concrete_op_name}"
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
    ret_top_func: FunctionWithCondition,
    domain: AbstractDomain,
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

    return eval_transfer_func(
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
    domain: AbstractDomain,
    helper_funcs: list[str],
    ret_top_func: FunctionWithCondition,
) -> Callable[
    [
        list[FunctionWithCondition],
        list[FunctionWithCondition],
    ],
    list[EvalResult],
]:
    "This function returns a simplified eval_func receiving transfer functions and base functions"
    return lambda transfer=list[FunctionWithCondition], base=list[
        FunctionWithCondition
    ]: (
        eval_transfer_func_helper(
            data_dir, transfer, base, ret_top_func, domain, helper_funcs
        )
    )


def tests_sampler_helper(
    domain: AbstractDomain,
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

    reject_sampler(
        domain,
        data_dir,
        samples,
        seed,
        helper_srcs + callee_srcs,
        base_func_names,
        base_func_srcs,
    )


def solution_set_tests_sampler(
    domain: AbstractDomain,
    data_dir: str,
    helper_srcs: list[str],
) -> Callable[[list[FunctionWithCondition], int, int], None]:
    return lambda base=list[
        FunctionWithCondition
    ], samples=int, seed=int: tests_sampler_helper(
        domain, data_dir, samples, seed, helper_srcs, base
    )


def save_solution(solution_module: ModuleOp, solution_str: str, outputs_folder: Path):
    with open(outputs_folder.joinpath("solution.cpp"), "w") as fout:
        fout.write(solution_str)
    with open(outputs_folder.joinpath("solution.mlir"), "w") as fout:
        print(solution_module, file=fout)


@dataclass
class HelperFuncs:
    crt_func: FuncOp
    instance_constraint_func: FuncOp
    domain_constraint_func: FuncOp
    op_constraint_func: FuncOp | None
    get_top_func: FuncOp
    transfer_func: FuncOp
    meet_func: FuncOp

    def items_to_print(self) -> list[FuncOp]:
        canditates = [
            self.get_top_func,
            self.instance_constraint_func,
            self.domain_constraint_func,
            self.op_constraint_func,
            self.meet_func,
        ]
        return [x for x in canditates if x is not None]

    def to_cpp(self) -> list[str]:
        return [print_concrete_function_to_cpp(self.crt_func)] + [
            print_to_cpp(x) for x in self.items_to_print()
        ]


def is_transfer_function(func: FuncOp) -> bool:
    return "applied_to" in func.attributes


def is_base_function(func: FuncOp) -> bool:
    return func.sym_name.data.startswith("part_solution_")


def convert_xfer_func(fn: FuncOp, ty: AbstractValueType):
    "Warning: this modifies the `FuncOp` in place"
    fn.function_type = FunctionType.from_lists([ty, ty], [ty])
    fn.body.block.insert_arg(ty, 0)
    fn.body.block.insert_arg(ty, 0)

    *_, op = fn.body.block.ops
    op.operands[-1].replace_by(fn.body.block.args[0])

    fn.body.block.erase_arg(fn.body.block.args[2])
    fn.body.block.erase_arg(fn.body.block.args[2])


def get_helper_funcs(p: Path, d: AbstractDomain) -> tuple[ModuleOp, HelperFuncs]:
    with open(p, "r") as f:
        module = Parser(ctx, f.read(), p.name).parse_op()
        assert isinstance(module, ModuleOp)

    fns = {x.sym_name.data: x for x in module.ops if isinstance(x, FuncOp)}
    FunctionCallInline(False, fns).apply(ctx, module)

    x = [x for x in fns.values() if is_transfer_function(x) and not is_base_function(x)]
    assert len(x) != 0, "No transfer function is found in input file"
    transfer_func = x[0]

    ty = AbstractValueType([TransIntegerType() for _ in range(d.vec_size)])
    convert_xfer_func(transfer_func, ty)

    if "concrete_op" in fns:
        crt_func = fns["concrete_op"]
    else:
        assert isa(at := transfer_func.attributes["applied_to"], ArrayAttr[StringAttr])
        concrete_func_name = at.data[0].data
        crt_func = get_concrete_function(concrete_func_name, None)

    op_con_fn = fns.get("op_constraint", None)

    def get_domain_fns(fp: str) -> FuncOp:
        dp = p.resolve().parent.parent.joinpath(str(d), fp)
        with open(dp, "r") as f:
            fn = Parser(ctx, f.read(), f.name).parse_op()
            assert isinstance(fn, FuncOp)

        return fn

    top = get_domain_fns("top.mlir")
    meet = get_domain_fns("meet.mlir")
    constraint = get_domain_fns("get_constraint.mlir")
    instance_constraint = get_domain_fns("get_instance_constraint.mlir")

    return module, HelperFuncs(
        crt_func=crt_func,
        instance_constraint_func=instance_constraint,
        domain_constraint_func=constraint,
        op_constraint_func=op_con_fn,
        get_top_func=top,
        transfer_func=transfer_func,
        meet_func=meet,
    )


def get_base_xfers(module: ModuleOp) -> list[FunctionWithCondition]:
    base_bodys: dict[str, FuncOp] = {}
    base_conds: dict[str, FuncOp] = {}
    base_transfers: list[FunctionWithCondition] = []
    fs = [x for x in module.ops if isinstance(x, FuncOp) and is_base_function(x)]

    for func in fs:
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

    return base_transfers


def setup_context(r: Random, use_full_i1_ops: bool) -> SynthesizerContext:
    c = SynthesizerContext(r)
    c.set_cmp_flags([0, 6, 7])
    if not use_full_i1_ops:
        c.use_basic_i1_ops()
    return c


def run(
    logger: logging.Logger,
    domain: AbstractDomain,
    num_programs: int,
    total_rounds: int,
    program_length: int,
    inv_temp: int,
    lbws: list[int],
    mbws: list[tuple[int, int]],
    hbws: list[tuple[int, int]],
    solution_size: int,
    num_iters: int,
    condition_length: int,
    num_abd_procs: int,
    random_seed: int | None,
    random_number_file: str | None,
    transfer_functions: Path,
    weighted_dsl: bool,
    num_unsound_candidates: int,
    outputs_folder: Path,
) -> EvalResult:
    assert min(lbws, default=4) >= 4 or domain != AbstractDomain.IntegerModulo
    EvalResult.init_bw_settings(
        set(lbws), set([t[0] for t in mbws]), set([t[0] for t in hbws])
    )

    logger.debug("Round_ID\tSound%\tUExact%\tDisReduce\tCost")

    random = Random(random_seed)
    random_seed = random.randint(0, 1_000_000) if random_seed is None else random_seed
    if random_number_file is not None:
        random.read_from_file(random_number_file)

    context = setup_context(random, False)
    context_weighted = setup_context(random, False)
    context_cond = setup_context(random, True)

    module, helper_funcs = get_helper_funcs(transfer_functions, domain)
    helper_funcs_cpp = helper_funcs.to_cpp()
    base_transfers = get_base_xfers(module)

    ret_top_func = FunctionWithCondition(construct_top_func(helper_funcs.transfer_func))
    ret_top_func.set_func_name("ret_top")

    data_dir = setup_eval(
        domain, lbws, mbws, hbws, random_seed, "\n".join(helper_funcs_cpp)
    )

    solution_eval_func = solution_set_eval_func(
        data_dir, domain, helper_funcs_cpp, ret_top_func
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
        f"Initial Solution. Sound:{init_cmp_res[0].get_sound_prop() * 100:.4f}% Exact: {init_cmp_res[0].get_exact_prop() * 100:.4f}%"
    )
    print(
        f"init_solution\t{init_cmp_res[0].get_sound_prop() * 100:.4f}%\t{init_cmp_res[0].get_exact_prop() * 100:.4f}%"
    )

    current_prog_len = program_length
    # current_prog_len = min(4, current_prog_len) # enable this for increasing program length
    current_total_rounds = total_rounds
    # current_total_rounds = min(500, total_rounds) # enable this for increasing total rounds
    current_num_abd_procs = num_abd_procs
    # current_num_abd_procs = min(0, num_abd_procs) # enable this for increasing number of abd procs
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
            helper_funcs.transfer_func,
            context,
            context_weighted,
            context_cond,
            random,
            solution_set,
            logger,
            helper_funcs.crt_func,
            helper_funcs.items_to_print(),
            ctx,
            num_programs,
            current_prog_len,
            condition_length,
            current_num_abd_procs,
            current_total_rounds,
            solution_size,
            inv_temp,
            num_unsound_candidates,
        )

        print_set_of_funcs_to_file(
            [f.to_str(eliminate_dead_code) for f in solution_set.solutions],
            ith_iter,
            outputs_folder,
        )

        final_cmp_res = solution_set.eval_improve([])
        lbw_mbw_log = "\n".join(
            f"bw: {res.bitwidth}, dist: {res.dist}, exact%: {res.get_exact_prop() * 100:.4f}"
            for res in final_cmp_res[0].get_low_med_res()
        )
        hbw_log = "\n".join(
            f"bw: {res.bitwidth}, dist: {res.dist}"
            for res in final_cmp_res[0].get_high_res()
        )
        logger.info(
            f"""Iter {ith_iter} Finished. Result of Current Solution: \n{lbw_mbw_log}\n{hbw_log}\n"""
        )

        print(
            f"Iteration {ith_iter} finished. Exact: {final_cmp_res[0].get_exact_prop() * 100:.4f}%, Size of the solution set: {solution_set.solutions_size}"
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
    cmp_results = eval_transfer_func(
        data_dir,
        ["solution"],
        [solution_str],
        [],
        [],
        helper_funcs_cpp,
        domain,
    )

    solution_result = cmp_results[0]
    print(
        f"last_solution\t{solution_result.get_sound_prop() * 100:.2f}%\t{solution_result.get_exact_prop() * 100:.2f}%"
    )

    return solution_result


def main() -> None:
    args = register_arguments("synth_transfer")

    if not args.outputs_folder.is_dir():
        args.outputs_folder.mkdir()

    logger = setup_loggers(args.outputs_folder, not args.quiet)
    [logger.info(f"{k}: {v}") for k, v in vars(args).items()]

    run(
        logger=logger,
        domain=AbstractDomain[args.domain],
        num_programs=args.num_programs,
        total_rounds=args.total_rounds,
        program_length=args.program_length,
        inv_temp=args.inv_temp,
        lbws=args.lbw,
        mbws=args.mbw,
        hbws=args.hbw,
        solution_size=args.solution_size,
        num_iters=args.num_iters,
        condition_length=args.condition_length,
        num_abd_procs=args.num_abd_procs,
        random_seed=args.random_seed,
        random_number_file=args.random_file,
        transfer_functions=args.transfer_functions,
        weighted_dsl=args.weighted_dsl,
        num_unsound_candidates=args.num_unsound_candidates,
        outputs_folder=args.outputs_folder,
    )


if __name__ == "__main__":
    main()
