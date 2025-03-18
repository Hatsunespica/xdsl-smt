from __future__ import annotations
from typing import Callable

from xdsl.dialects.builtin import StringAttr
from xdsl.dialects.func import FuncOp, CallOp, ReturnOp
from xdsl.ir import Operation

from xdsl_smt.utils.compare_result import CompareResult
from abc import ABC, abstractmethod
import logging

from xdsl_smt.utils.func_with_cond import FuncWithCond
from xdsl_smt.utils.synthesizer_context import SynthesizerContext


def rename_functions(lst: list[FuncOp], prefix: str) -> list[str]:
    func_names: list[str] = []
    for i, func in enumerate(lst):
        func_names.append(prefix + str(i))
        func.sym_name = StringAttr(func_names[-1])
    return func_names


"""
This class is an abstract class for maintaining solutions.
It supports to generate the meet of solutions
"""


class SolutionSet(ABC):
    solutions_size: int
    solutions: list[FuncWithCond]
    precise_set: list[FuncOp]
    lower_to_cpp: Callable[[FuncOp], str]
    eliminate_dead_code: Callable[[FuncOp], FuncOp]

    """
    list of name of transfer functions
    list of transfer functions
    list of name of base functions
    list of base functions
    """
    eval_func: Callable[[list[FuncWithCond], list[FuncWithCond]], list[CompareResult]]

    def __init__(
        self,
        initial_solutions: list[FuncWithCond],
        lower_to_cpp: Callable[[FuncOp], str],
        eliminate_dead_code: Callable[[FuncOp], FuncOp],
        eval_func: Callable[
            [
                list[FuncWithCond],
                list[FuncWithCond],
            ],
            list[CompareResult],
        ],
    ):
        rename_functions([fc.func for fc in initial_solutions], "partial_solution_")
        self.solutions = initial_solutions
        self.solution_conds = [None] * len(initial_solutions)
        self.solutions_size = len(initial_solutions)
        self.lower_to_cpp = lower_to_cpp
        self.eliminate_dead_code = eliminate_dead_code
        self.eval_func = eval_func
        self.precise_set = []
        # self.eval_func = lambda transfer=list[FuncOp], base=list[FuncOp]: (
        #     eval_func_with_cond(
        #         transfer,
        #         [],
        #         base,
        #         [],
        #     )
        # )

    def eval_improve(self, transfers: list[FuncWithCond]) -> list[CompareResult]:
        return self.eval_func(transfers, self.solutions)

    # def eval_improve(self, transfers: list[FuncOp]) -> list[CompareResult]:
    #     return self.eval_improve_with_cond(transfers, [])

    @abstractmethod
    def construct_new_solution_set(
        self,
        new_candidates_sp: list[FuncWithCond],
        new_candidates_p: list[FuncOp],
        new_candidates_c: list[FuncWithCond],
    ) -> SolutionSet:
        ...

    def has_solution(self) -> bool:
        return self.solutions_size != 0

    def generate_solution(self) -> FuncOp:
        assert self.has_solution()
        solutions = self.solutions
        result = FuncOp("solution", solutions[0].func.function_type)
        result_type = result.function_type.outputs.data
        part_result: list[CallOp] = []
        for ith, func_with_cond in enumerate(solutions):
            cur_func_name = "partial_solution_" + str(ith)
            func_with_cond.func.sym_name = StringAttr("partial_solution_" + str(ith))
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
        return result

    def generate_solution_and_cpp(self) -> tuple[FuncOp, str]:
        final_solution = self.generate_solution()
        solution_str = ""
        for sol in self.solutions:
            solution_str += self.lower_to_cpp(sol.func)
            solution_str += "\n"
        solution_str += self.lower_to_cpp(final_solution)
        solution_str += "\n"
        return final_solution, solution_str


"""
This class maintains a list of solutions with a specified size
"""


class SizedSolutionSet(SolutionSet):
    size: int

    def __init__(
        self,
        size: int,
        initial_solutions: list[FuncWithCond],
        lower_to_cpp: Callable[[FuncOp], str],
        eliminate_dead_code: Callable[[FuncOp], FuncOp],
        eval_func_with_cond: Callable[
            [
                list[FuncWithCond],
                list[FuncWithCond],
            ],
            list[CompareResult],
        ],
    ):
        super().__init__(
            initial_solutions, lower_to_cpp, eliminate_dead_code, eval_func_with_cond
        )
        self.size = size

    def construct_new_solution_set(
        self,
        new_candidates_sp: list[FuncWithCond],
        new_candidates_p: list[FuncOp],
        new_candidates_c: list[FuncWithCond],
    ) -> SolutionSet:
        candidates = self.solutions + new_candidates_sp
        if len(candidates) <= self.size:
            return SizedSolutionSet(
                self.size,
                candidates.copy(),
                self.lower_to_cpp,
                self.eliminate_dead_code,
                self.eval_func,
            )
        rename_functions([fc.func for fc in candidates], "part_solution_")
        ref_funcs: list[FuncWithCond] = []

        # First select a function with maximal precise
        result: list[CompareResult] = self.eval_func(candidates, ref_funcs)
        index = 0
        num_exacts = 0
        # cost = 2
        for i in range(len(result)):
            if result[i].exacts > num_exacts:
                index = i
                num_exacts = result[i].exacts
            # temporarily comment this out since (1) now the cost depends on both synthcontext and cmpresult (2) I think #exacts is enough to rank tfs
            #     cost = result[i].get_cost()
            # elif result[i].exacts == num_exacts and result[i].get_cost() > cost:
            #     index = i
            #     cost = result[i].get_cost()

        ref_funcs.append(candidates.pop(index))

        # Greedy select all subsequent functions
        for _ in range(1, self.size + 1):
            index = 0
            num_exacts = 0
            # cost = 2
            result: list[CompareResult] = self.eval_func(candidates, ref_funcs)
            for ith_result in range(len(result)):
                if result[ith_result].unsolved_exacts > num_exacts:
                    index = ith_result
                    num_exacts = result[ith_result].unsolved_exacts
            # Xuanyu: temporarily comment this out since (1) now the cost depends on both mcmc_sampler and cmp_result (2) I think #exacts is enough to rank tfs
            #     cost = result[ith_result].get_cost()
            # elif (
            #     result[ith_result].unsolved_exacts == num_exacts
            #     and cost > result[ith_result].get_cost()
            # ):
            #     index = ith_result
            #     cost = result[ith_result].get_cost()
            ref_funcs.append(candidates.pop(index))

        return SizedSolutionSet(
            self.size,
            ref_funcs,
            self.lower_to_cpp,
            self.eliminate_dead_code,
            self.eval_func,
        )


"""
This class maintains a list of solutions without a specified size
"""


class UnsizedSolutionSet(SolutionSet):
    logger: logging.Logger

    def __init__(
        self,
        initial_solutions: list[FuncWithCond],
        lower_to_cpp: Callable[[FuncOp], str],
        eval_func_with_cond: Callable[
            [
                list[FuncWithCond],
                list[FuncWithCond],
            ],
            list[CompareResult],
        ],
        logger: logging.Logger,
        eliminate_dead_code: Callable[[FuncOp], FuncOp],
    ):
        super().__init__(
            initial_solutions, lower_to_cpp, eliminate_dead_code, eval_func_with_cond
        )
        self.logger = logger

    def construct_new_solution_set(
        self,
        new_candidates_sp: list[FuncWithCond],
        new_candidates_p: list[FuncOp],
        new_candidates_c: list[FuncWithCond],
    ) -> SolutionSet:
        candidates = self.solutions + new_candidates_sp + new_candidates_c
        self.logger.info(f"Size of new candidates: {len(new_candidates_sp)}")
        self.logger.info(f"Size of new conditional candidates: {len(new_candidates_c)}")
        self.logger.info(f"Size of solutions: {len(candidates)}")
        # cur_most_e: float = 0
        #     cpp_code = self.lower_to_cpp(self.eliminate_dead_code(func))
        #
        #     cmp_results: list[CompareResult] = self.eval_func(
        #         [candidate_names[i]],
        #         [cpp_code],
        #         self.solution_names,
        #         self.solution_srcs,
        #     )
        #     if cmp_results[0].exacts > cur_most_e:
        #         self.logger.info(
        #             f"Add a new transformer {i}. Exact: {cmp_results[0].get_exact_prop() * 100:.2f}%, Precision: {cmp_results[0].get_bitwise_precision() * 100:.2f}%"
        #         )
        #         self.logger.debug(cmp_results[0])
        #         cur_most_e = cmp_results[0].exacts
        #         self.solutions.append(func)
        #         self.solution_names.append(candidate_names[i])
        #         self.solution_srcs.append(cpp_code)
        #         self.solutions_size += 1
        #
        # self.logger.info(f"Size of the sound set: {self.solutions_size}")

        # if cur_most_e == 0:
        #     self.logger.info(f"No improvement in the last one iteration!")

        # Remove redundant transformers
        # i = 0
        # while i < self.solutions_size:
        #     cmp_results: list[CompareResult] = self.eval_func(
        #         [self.solution_names[i]],
        #         [self.solution_srcs[i]],
        #         self.solution_names[:i] + self.solution_names[i + 1 :],
        #         self.solution_srcs[:i] + self.solution_srcs[i + 1 :],
        #     )
        #     if cmp_results[0].unsolved_exacts == 0:
        #         del self.solutions[i]
        #         del self.solution_names[i]
        #         del self.solution_srcs[i]
        #         self.solutions_size -= 1
        #     else:
        #         i += 1

        self.solutions = []
        self.logger.info("Reset solution set...")
        num_cond_solutions = 0
        while len(candidates) > 0:
            index = 0
            most_unsol_e = 0
            result = self.eval_improve(candidates)
            for ith_result in range(len(result)):
                if result[ith_result].unsolved_exacts > most_unsol_e:
                    index = ith_result
                    most_unsol_e = result[ith_result].unsolved_exacts
            if most_unsol_e == 0:
                break

            if candidates[index] in new_candidates_sp:
                log_str = "Add a new transformer"
            elif candidates[index] in new_candidates_c:
                log_str = "Add a new transformer (cond)"
                num_cond_solutions += 1
            else:
                if candidates[index].cond is None:
                    log_str = "Add a existing transformer"
                else:
                    log_str = "Add a existing transformer (cond)"
                    num_cond_solutions += 1

            self.logger.info(
                f"{log_str}. Exact: {result[index].get_exact_prop() * 100:.2f}%, Precision: {result[index].get_bitwise_precision() * 100:.2f}%"
            )

            self.solutions.append(candidates.pop(index))

        self.logger.info(
            f"The number of solutions after reseting: {len(self.solutions)}"
        )
        self.logger.info(f"The number of conditional solutions: {num_cond_solutions}")

        precise_candidates = self.precise_set + new_candidates_p
        result = self.eval_improve([FuncWithCond(f) for f in precise_candidates])

        sorted_pairs = sorted(
            zip(precise_candidates, result),
            reverse=True,
            key=lambda pair: pair[1].unsolved_exacts,
        )
        K = 5
        top_k = sorted_pairs[:K]
        self.logger.info(f"Top {K} Precise candidates:")
        self.precise_set = []
        for cand, res in top_k:
            self.logger.info(
                f"unsolved_exact: {res.get_unsolved_exact_prop() * 100:.2f}%, sound: {res.get_sound_prop() * 100:.2f}%"
            )
            self.precise_set.append(cand)
        # return UnsizedSolutionSet(
        #     self.solutions.copy(), self.lower_to_cpp, self.eval_func, self.logger, self.eliminate_dead_code
        # )
        return self

    """
    Set weights in context according to the frequencies of each DSL operation that appear in func in solution set
    """

    def learn_weights(self, context: SynthesizerContext):
        freq_i1: dict[type(Operation), int] = {}
        freq_int: dict[type(Operation), int] = {}

        def add_another_dict(dict1: dict, dict2: dict):
            for key, value in dict2.items():
                dict1[key] = dict1.get(key, 0) + value

        for i in range(len(self.solutions)):
            cmp_results: list[CompareResult] = self.eval_func(
                [self.solutions[i]],
                self.solutions[:i] + self.solutions[i + 1 :],
            )
            res = cmp_results[0]
            self.logger.info(
                f"func {i}: #exact {res.exacts - res.unsolved_exacts} -> {res.exacts}, new exact%: {res.get_new_exact_prop()}, prec: {res.base_edit_dis} -> {res.edit_dis}, prec improve%: {res.get_prec_improve_avg()}"
            )
            if res.get_new_exact_prop() > 0.005:
                d_int, d_i1 = SynthesizerContext.count_op_frequency(
                    self.eliminate_dead_code(self.solutions[i].func)
                )
                add_another_dict(freq_int, d_int)
                add_another_dict(freq_i1, d_i1)

        context.update_i1_weights(freq_i1)
        context.update_int_weights(freq_int)

        for key, value in context.int_weights.items():
            self.logger.info(f"{key}: {value}")
