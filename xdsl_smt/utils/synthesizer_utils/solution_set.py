from __future__ import annotations

import io
from typing import Callable
from abc import ABC, abstractmethod
import logging

from xdsl.context import Context
from xdsl.dialects.builtin import ModuleOp
from xdsl.dialects.func import FuncOp, CallOp, ReturnOp

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from xdsl_smt.utils.synthesizer_utils.verifier_utils import verify_transfer_function

from xdsl_smt.utils.synthesizer_utils.function_with_condition import (
    FunctionWithCondition,
)
from xdsl_smt.utils.synthesizer_utils.synthesizer_context import SynthesizerContext


def rename_functions(lst: list[FunctionWithCondition], prefix: str) -> list[str]:
    func_names: list[str] = []
    for i, func in enumerate(lst):
        func_names.append(prefix + str(i))
        func.set_func_name(func_names[-1])
    return func_names


def verify_function(
    func: FunctionWithCondition,
    concrete_op: FuncOp,
    helper_funcs: list[FuncOp],
    ctx: Context,
) -> int:
    cur_helper = [func.func]
    if func.cond is not None:
        cur_helper.append(func.cond)
    return verify_transfer_function(
        func.get_function(), concrete_op, cur_helper + helper_funcs, ctx, 1, 32
    )


class SolutionSet(ABC):
    "This class is an abstract class for maintaining solutions. It supports to generate the meet of solutions"

    solutions_size: int
    solutions: list[FunctionWithCondition]
    precise_set: list[FuncOp]
    lower_to_cpp: Callable[[FuncOp], str]
    eliminate_dead_code: Callable[[FuncOp], FuncOp]
    is_perfect: bool

    """
    list of name of transfer functions
    list of transfer functions
    list of name of base functions
    list of base functions
    """
    eval_func: Callable[
        [list[FunctionWithCondition], list[FunctionWithCondition]], list[EvalResult]
    ]

    tests_sampler: Callable[[list[FunctionWithCondition], int, int], None]
    logger: logging.Logger

    def __init__(
        self,
        initial_solutions: list[FunctionWithCondition],
        lower_to_cpp: Callable[[FuncOp], str],
        eliminate_dead_code: Callable[[FuncOp], FuncOp],
        eval_func: Callable[
            [
                list[FunctionWithCondition],
                list[FunctionWithCondition],
            ],
            list[EvalResult],
        ],
        tests_sampler: Callable[[list[FunctionWithCondition], int, int], None],
        logger: logging.Logger,
        is_perfect: bool = False,
    ):
        rename_functions(initial_solutions, "partial_solution_")
        self.solutions = initial_solutions
        self.solutions_size = len(initial_solutions)
        self.lower_to_cpp = lower_to_cpp
        self.eliminate_dead_code = eliminate_dead_code
        self.eval_func = eval_func
        self.tests_sampler = tests_sampler
        self.logger = logger
        self.precise_set = []
        self.is_perfect = is_perfect

    def eval_improve(self, transfers: list[FunctionWithCondition]) -> list[EvalResult]:
        return self.eval_func(transfers, self.solutions)

    def sample_unsolved_tests(self, samples: int, seed: int):
        self.tests_sampler(self.solutions, samples, seed)

    def sample_unsolved_tests_up_to(self, desired_size: int, seed: int) -> int:
        res = self.eval_improve([])[0]
        unsolved_cases = res.get_unsolved_cases()
        if unsolved_cases == 0:
            return -1
        samples = desired_size - unsolved_cases
        if samples <= 0:
            return 0
        else:
            self.sample_unsolved_tests(samples, seed)
            return samples

    @abstractmethod
    def construct_new_solution_set(
        self,
        new_candidates_sp: list[FunctionWithCondition],
        new_candidates_p: list[FuncOp],
        new_candidates_c: list[FunctionWithCondition],
        # Parameters used by SMT verifier
        concrete_op: FuncOp,
        helper_funcs: list[FuncOp],
        num_unsound_candidates: int,
        ctx: Context,
    ) -> SolutionSet:
        ...

    def has_solution(self) -> bool:
        return self.solutions_size != 0

    def generate_solution(self) -> tuple[FuncOp, list[FuncOp]]:
        assert self.has_solution()
        solutions = self.solutions
        result = FuncOp("solution", solutions[0].func.function_type)
        result_type = result.function_type.outputs.data
        part_result: list[CallOp] = []
        part_solution_funcs: list[FuncOp] = []
        for ith, func_with_cond in enumerate(solutions):
            cur_func_name = "partial_solution_" + str(ith)
            func_with_cond.set_func_name(cur_func_name)
            part_solution_funcs.append(func_with_cond.get_function())
            part_result.append(CallOp(cur_func_name, result.args, result_type))
        if len(part_result) == 1:
            result.body.block.add_ops(part_result + [ReturnOp(part_result[-1])])
        else:
            meet_result: list[CallOp] = [
                CallOp(
                    "meet",
                    [part_result[0], part_result[1]],
                    result_type,
                )
            ]
            for i in range(2, len(part_result)):
                meet_result.append(
                    CallOp(
                        "meet",
                        [meet_result[-1], part_result[i]],
                        result_type,
                    )
                )
            result.body.block.add_ops(
                part_result + meet_result + [ReturnOp(meet_result[-1])]
            )
        return result, part_solution_funcs

    def generate_solution_and_cpp(self) -> tuple[ModuleOp, str]:
        final_solution, part_solutions = self.generate_solution()
        function_lst: list[FuncOp] = []
        solution_str = ""
        for sol in self.solutions:
            func_body = self.eliminate_dead_code(sol.func)
            function_lst.append(func_body)
            solution_str += self.lower_to_cpp(func_body)
            solution_str += "\n"
            if sol.cond is not None:
                func_cond = self.eliminate_dead_code(sol.cond)
                function_lst.append(func_cond)
                solution_str += self.lower_to_cpp(func_cond)
                solution_str += "\n"

        for sol in part_solutions:
            solution_str += self.lower_to_cpp(sol)
            solution_str += "\n"
        solution_str += self.lower_to_cpp(final_solution)
        solution_str += "\n"

        function_lst += part_solutions
        function_lst.append(final_solution)
        final_module = ModuleOp([])
        final_module.body.block.add_ops(function_lst)
        return final_module, solution_str


class UnsizedSolutionSet(SolutionSet):
    "This class maintains a list of solutions without a specified size"

    def __init__(
        self,
        initial_solutions: list[FunctionWithCondition],
        lower_to_cpp: Callable[[FuncOp], str],
        eval_func_with_cond: Callable[
            [
                list[FunctionWithCondition],
                list[FunctionWithCondition],
            ],
            list[EvalResult],
        ],
        tests_sampler: Callable[[list[FunctionWithCondition], int, int], None],
        logger: logging.Logger,
        eliminate_dead_code: Callable[[FuncOp], FuncOp],
        is_perfect: bool = False,
    ):
        super().__init__(
            initial_solutions,
            lower_to_cpp,
            eliminate_dead_code,
            eval_func_with_cond,
            tests_sampler,
            logger,
            is_perfect,
        )

    def handle_inconsistent_result(self, f: FunctionWithCondition):
        func_str, helper_str = f.get_function_str(self.lower_to_cpp)
        func_op = f.get_function()
        for s in helper_str:
            self.logger.critical(s + "\n")
        self.logger.critical(func_str)
        str_output = io.StringIO()
        print(self.eliminate_dead_code(f.func), file=str_output)
        if f.cond is not None:
            print(self.eliminate_dead_code(f.cond), file=str_output)
        print(func_op, file=str_output)
        func_op_str = str_output.getvalue()
        self.logger.error(func_op_str)
        raise Exception("Inconsistent between eval engine and verifier")

    def construct_new_solution_set(
        self,
        new_candidates_sp: list[FunctionWithCondition],
        new_candidates_p: list[FuncOp],
        new_candidates_c: list[FunctionWithCondition],
        concrete_op: FuncOp,
        helper_funcs: list[FuncOp],
        num_unsound_candidates: int,
        ctx: Context,
    ) -> SolutionSet:
        candidates = self.solutions + new_candidates_sp + new_candidates_c
        rename_functions(candidates, "part_solution_")
        self.logger.info(f"Size of new candidates: {len(new_candidates_sp)}")
        self.logger.info(f"Size of new conditional candidates: {len(new_candidates_c)}")
        self.logger.info(f"Size of solutions: {len(candidates)}")
        self.solutions = []
        self.logger.info("Reset solution set...")
        num_cond_solutions = 0

        while len(candidates) > 0:
            result = self.eval_improve(candidates)
            if (
                result[0].get_base_dist() == 0
            ):  # current solution set is already perfect
                break
            cand, max_improve_res = max(
                zip(candidates, result), key=lambda x: x[1].get_potential_improve()
            )
            if max_improve_res.get_potential_improve() == 0:
                break

            body_number = cand.func.attributes["number"]
            cond_number = (
                "None" if cand.cond is None else cand.cond.attributes["number"]
            )

            if (cand in new_candidates_sp) or (cand in new_candidates_c):
                unsound_bit = verify_function(cand, concrete_op, helper_funcs, ctx)
                if unsound_bit != 0:
                    self.logger.info(
                        f"Skip a unsound function at bit width {unsound_bit}, body: {body_number}, cond: {cond_number}"
                    )
                    # Todo: Remove hard encoded bitwidth
                    if unsound_bit <= 4:
                        self.handle_inconsistent_result(cand)
                    candidates.remove(cand)
                    continue

            if cand in new_candidates_sp:
                log_str = "Add a new transformer"
            elif cand in new_candidates_c:
                log_str = "Add a new transformer (cond)"
                num_cond_solutions += 1
            else:
                if cand.cond is None:
                    log_str = "Add a existing transformer"
                else:
                    log_str = "Add a existing transformer (cond)"
                    num_cond_solutions += 1
            from_weighted_dsl = "from_weighted_dsl" in cand.func.attributes
            self.logger.info(
                f"{log_str}, body: {body_number}, cond: {cond_number}. After adding, Exact: {max_improve_res.get_exact_prop() * 100:.2f}%, Dist: {max_improve_res.get_dist():.2f}, weighted?: {from_weighted_dsl}"
            )
            candidates.remove(cand)
            self.solutions.append(cand)

        self.logger.info(
            f"The number of solutions after reseting: {len(self.solutions)}"
        )
        self.logger.info(f"The number of conditional solutions: {num_cond_solutions}")
        self.solutions_size = len(self.solutions)

        final_result = self.eval_improve([])[0]
        if final_result.get_unsolved_cases() == 0:
            self.is_perfect = True
            return self

        precise_candidates = self.precise_set + new_candidates_p
        precise_candidates_to_eval = [
            FunctionWithCondition(f.clone()) for f in precise_candidates
        ]
        rename_functions(precise_candidates_to_eval, "precise_candidates_")
        result = self.eval_improve(precise_candidates_to_eval)

        sorted_pairs = sorted(
            zip(precise_candidates, result),
            reverse=True,
            key=lambda x: x[1].get_potential_improve(),
        )
        top_k = sorted_pairs[:num_unsound_candidates]
        self.logger.info(f"Top {num_unsound_candidates} Precise candidates:")
        self.precise_set = []
        for cand, res in top_k:
            body_number = cand.attributes["number"]
            self.logger.info(
                f"{body_number}\tunsolved_exact: {res.get_unsolved_exact_prop() * 100:.2f}%, sound: {res.get_sound_prop() * 100:.2f}%, dist_reduce: {res.base_dist:.2f} -> {res.sound_dist:.2f}"
            )
            self.precise_set.append(cand)

        return self

    def learn_weights(self, context: SynthesizerContext):
        "Set weights in context according to the frequencies of each DSL operation that appear in func in solution set"
        self.logger.info("Improvement by each individual function")
        learn_form_funcs: list[FuncOp] = []
        for i, sol in enumerate(self.solutions):
            cmp_results: list[EvalResult] = self.eval_func(
                [sol],
                self.solutions[:i] + self.solutions[i + 1 :],
            )
            res = cmp_results[0]
            to_learn = res.get_new_exact_prop() > 0.005
            body_number = sol.func.attributes["number"]
            cond_number = "None" if sol.cond is None else sol.cond.attributes["number"]
            self.logger.info(
                f"\tbody {body_number}, cond {cond_number} : #exact {res.get_exacts() - res.get_unsolved_exacts()} -> {res.get_exacts()}, dist_improve: {res.get_potential_improve():3f}%, cond?: {self.solutions[i].cond is not None}, learn?: {to_learn}"
            )
            if to_learn:
                learn_form_funcs.append(self.eliminate_dead_code(sol.func))

        freq_of_learn_funcs = SynthesizerContext.count_op_frequency(learn_form_funcs)
        context.update_weights(freq_of_learn_funcs)

        self.logger.info("Current Weights:")
        for _, weights in context.op_weights.items():
            for key, value in weights.items():
                self.logger.info(f"\t{key}: {value}")
