import logging
import time

from xdsl.context import Context
from xdsl.dialects.builtin import StringAttr
from xdsl.dialects.func import FuncOp

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult
from xdsl_smt.utils.synthesizer_utils.cost_model import (
    sound_and_precise_cost,
    precise_cost,
    abduction_cost,
    decide,
)
from xdsl_smt.utils.synthesizer_utils.function_with_condition import (
    FunctionWithCondition,
)
from xdsl_smt.utils.synthesizer_utils.mcmc_sampler import MCMCSampler
from xdsl_smt.utils.synthesizer_utils.random import Random
from xdsl_smt.utils.synthesizer_utils.solution_set import SolutionSet
from xdsl_smt.utils.synthesizer_utils.synthesizer_context import SynthesizerContext


def build_eval_list(
    mcmc_proposals: list[FuncOp],
    sp: range,
    p: range,
    c: range,
    prec_func_after_distribute: list[FuncOp],
) -> list[FunctionWithCondition]:
    """
    build the parameters of eval_transfer_func
    input:
    mcmc_proposals =  [ ..mcmc_sp.. , ..mcmc_p.. , ..mcmc_c.. ]
    output:
    funcs          =  [ ..mcmc_sp.. , ..mcmc_p.. ,..prec_set..]
    conds          =  [  nothing    ,  nothing   , ..mcmc_c.. ]
    """
    lst: list[FunctionWithCondition] = []
    for i in sp:
        fwc = FunctionWithCondition(mcmc_proposals[i].clone())
        fwc.set_func_name(f"{mcmc_proposals[i].sym_name.data}{i}")
        lst.append(fwc)
    for i in p:
        fwc = FunctionWithCondition(mcmc_proposals[i].clone())
        fwc.set_func_name(f"{mcmc_proposals[i].sym_name.data}{i}")
        lst.append(fwc)
    for i in c:
        prec_func = prec_func_after_distribute[i - c.start].clone()
        fwc = FunctionWithCondition(prec_func, mcmc_proposals[i].clone())
        fwc.set_func_name(f"{prec_func.sym_name.data}_abd_{i}")
        lst.append(fwc)

    return lst


def mcmc_setup(
    solution_set: SolutionSet, num_abd_proc: int, num_programs: int
) -> tuple[range, range, range, int, list[FuncOp]]:
    """
    A mcmc sampler use one of 3 modes: sound & precise, precise, condition
    This function specify which mode should be used for each mcmc sampler
    For example, mcmc samplers with index in sp_range should use "sound&precise"
    """

    # p_size = num_abd_proc // 2
    # c_size = num_abd_proc // 2
    p_size = 0
    c_size = num_abd_proc
    sp_size = num_programs - p_size - c_size

    if len(solution_set.precise_set) == 0:
        sp_size += c_size
        c_size = 0

    sp_range = range(0, sp_size)
    p_range = range(sp_size, sp_size + p_size)
    c_range = range(sp_size + p_size, sp_size + p_size + c_size)

    prec_set_after_distribute: list[FuncOp] = []

    if c_size > 0:
        # Distribute the precise funcs into c_range
        prec_set_size = len(solution_set.precise_set)
        base_count = c_size // prec_set_size
        remainder = c_size % prec_set_size
        for i, item in enumerate(solution_set.precise_set):
            for _ in range(base_count + (1 if i < remainder else 0)):
                prec_set_after_distribute.append(item.clone())

    num_programs = sp_size + p_size + c_size

    return sp_range, p_range, c_range, num_programs, prec_set_after_distribute


def synthesize_one_iteration(
    # Necessary items
    ith_iter: int,
    func: FuncOp,
    context_regular: SynthesizerContext,
    context_weighted: SynthesizerContext,
    context_cond: SynthesizerContext,
    random: Random,
    solution_set: SolutionSet,
    logger: logging.Logger,
    concrete_func: FuncOp,
    helper_funcs: list[FuncOp],
    ctx: Context,
    # Global arguments
    num_programs: int,
    program_length: int,
    cond_length: int,
    num_abd_procs: int,
    total_rounds: int,
    solution_size: int,
    inv_temp: int,
    num_unsound_candidates: int,
) -> SolutionSet:
    "Given ith_iter, performs total_rounds mcmc sampling"
    mcmc_samplers: list[MCMCSampler] = []

    sp_range, p_range, c_range, num_programs, prec_set_after_distribute = mcmc_setup(
        solution_set, num_abd_procs, num_programs
    )
    sp_size = sp_range.stop - sp_range.start
    p_size = p_range.stop - p_range.start

    for i in range(num_programs):
        if i in sp_range:
            spl = MCMCSampler(
                func,
                context_regular
                if i < (sp_range.start + sp_range.stop) // 2
                else context_weighted,
                sound_and_precise_cost,
                program_length,
                random_init_program=True,
            )
        elif i in p_range:
            spl = MCMCSampler(
                func,
                context_regular
                if i < (p_range.start + p_range.stop) // 2
                else context_weighted,
                precise_cost,
                program_length,
                random_init_program=True,
            )
        else:
            spl = MCMCSampler(
                func,
                context_cond,
                abduction_cost,
                cond_length,
                random_init_program=True,
                is_cond=True,
            )

        mcmc_samplers.append(spl)

    transfers = [spl.get_current() for spl in mcmc_samplers]
    func_with_cond_lst = build_eval_list(
        transfers, sp_range, p_range, c_range, prec_set_after_distribute
    )

    cmp_results = solution_set.eval_improve(func_with_cond_lst)

    for i, cmp in enumerate(cmp_results):
        mcmc_samplers[i].current_cmp = cmp

    cost_data = [[spl.compute_current_cost()] for spl in mcmc_samplers]

    # These 3 lists store "good" transformers during the search
    sound_most_improve_tfs: list[tuple[FuncOp, EvalResult, int]] = []
    most_improve_tfs: list[tuple[FuncOp, EvalResult, int]] = []
    lowest_cost_tfs: list[tuple[FuncOp, EvalResult, int]] = []
    for i, spl in enumerate(mcmc_samplers):
        init_tf = spl.current.func.clone()
        init_tf.attributes["number"] = StringAttr(f"{ith_iter}_{0}_{i}")
        sound_most_improve_tfs.append((init_tf, spl.current_cmp, 0))
        most_improve_tfs.append((init_tf, spl.current_cmp, 0))
        lowest_cost_tfs.append((init_tf, spl.current_cmp, 0))

    # MCMC start
    logger.info(
        f"Iter {ith_iter}: Start {num_programs - len(c_range)} MCMC to sampling programs of length {program_length}. Start {len(c_range)} MCMC to sample abductions. Each one is run for {total_rounds} steps..."
    )

    for rnd in range(total_rounds):
        transfers = [spl.sample_next().get_current() for spl in mcmc_samplers]

        func_with_cond_lst = build_eval_list(
            transfers, sp_range, p_range, c_range, prec_set_after_distribute
        )

        start = time.time()
        cmp_results = solution_set.eval_improve(func_with_cond_lst)
        end = time.time()
        used_time = end - start

        for i, (spl, res) in enumerate(zip(mcmc_samplers, cmp_results)):
            proposed_cost = spl.compute_cost(res)
            current_cost = spl.compute_current_cost()
            decision = decide(random.random(), inv_temp, current_cost, proposed_cost)
            if decision:
                spl.accept_proposed(res)
                cloned_func = spl.current.func.clone()
                cloned_func.attributes["number"] = StringAttr(f"{ith_iter}_{rnd}_{i}")
                tmp_tuple = (cloned_func, res, rnd)
                # Update sound_most_exact_tfs
                if (
                    res.is_sound()
                    and res.get_improve() > sound_most_improve_tfs[i][1].get_improve()
                ):
                    sound_most_improve_tfs[i] = tmp_tuple
                # Update most_exact_tfs
                if (
                    res.get_unsolved_exacts()
                    > most_improve_tfs[i][1].get_unsolved_exacts()
                ):
                    most_improve_tfs[i] = tmp_tuple
                # Update lowest_cost_tfs
                if proposed_cost < spl.compute_cost(lowest_cost_tfs[i][1]):
                    lowest_cost_tfs[i] = tmp_tuple

            else:
                spl.reject_proposed()

        for i, spl in enumerate(mcmc_samplers):
            res_cost = spl.compute_current_cost()
            sound_prop = spl.current_cmp.get_sound_prop() * 100
            exact_prop = spl.current_cmp.get_unsolved_exact_prop() * 100
            avg_dist_norm = spl.current_cmp.get_unsolved_dist_avg_norm()

            logger.debug(
                f"{ith_iter}_{rnd}_{i}\t{sound_prop:.2f}%\t{exact_prop:.2f}%\t{avg_dist_norm:.3f}\t{res_cost:.3f}"
            )

            cost_data[i].append(res_cost)

        logger.debug(f"Used Time: {used_time:.2f}")
        # Print the current best result every K rounds
        if rnd % 250 == 100 or rnd == total_rounds - 1:
            logger.debug("Sound transformers with most exact outputs:")
            for i in range(num_programs):
                res = sound_most_improve_tfs[i][1]
                if res.is_sound():
                    logger.debug(f"{i}_{sound_most_improve_tfs[i][2]}\n{res}")
            logger.debug("Transformers with most unsolved exact outputs:")
            for i in range(num_programs):
                logger.debug(f"{i}_{most_improve_tfs[i][2]}\n{most_improve_tfs[i][1]}")
            logger.debug("Transformers with lowest cost:")
            for i in range(num_programs):
                logger.debug(f"{i}_{lowest_cost_tfs[i][2]}\n{lowest_cost_tfs[i][1]}")

    candidates_sp: list[FunctionWithCondition] = []
    candidates_p: list[FuncOp] = []
    candidates_c: list[FunctionWithCondition] = []
    if solution_size == 0:
        for i in list(sp_range) + list(p_range):
            if (
                sound_most_improve_tfs[i][1].is_sound()
                and sound_most_improve_tfs[i][1].get_improve() > 0
            ):
                candidates_sp.append(
                    FunctionWithCondition(sound_most_improve_tfs[i][0])
                )
            if (
                not most_improve_tfs[i][1].is_sound()
                and most_improve_tfs[i][1].get_unsolved_exacts() > 0
            ):
                candidates_p.append(most_improve_tfs[i][0])
        for i in c_range:
            if (
                sound_most_improve_tfs[i][1].is_sound()
                and sound_most_improve_tfs[i][1].get_improve() > 0
            ):
                candidates_c.append(
                    FunctionWithCondition(
                        prec_set_after_distribute[i - sp_size - p_size],
                        sound_most_improve_tfs[i][0],
                    )
                )
    else:
        for i in range(num_programs):
            if sound_most_improve_tfs[i][1].is_sound():
                candidates_sp.append(
                    FunctionWithCondition(sound_most_improve_tfs[i][0])
                )
            if lowest_cost_tfs[i][1].is_sound():
                candidates_sp.append(FunctionWithCondition(lowest_cost_tfs[i][0]))

    # loaded_spls = mcmc_samplers
    # neighbor_tfs : list[list[tuple[float, float, float]]] =[[] for _ in loaded_spls]
    # for _ in range(300):
    #     transfers = [spl.sample_next().get_current() for spl in loaded_spls]
    #     func_with_cond_lst = build_eval_list(
    #         transfers, sp_range, p_range, c_range, prec_set_after_distribute
    #     )
    #     cmp_results = solution_set.eval_improve(func_with_cond_lst)
    #     cost_data = [[spl.compute_current_cost()] for spl in loaded_spls]
    #     for i, (spl, res) in enumerate(zip(loaded_spls, cmp_results)):
    #         proposed_cost = spl.compute_cost(res)
    #         current_cost = spl.compute_current_cost()
    #         neighbor_tfs[i].append((res.get_sound_prop(), res.get_unsolved_exact_prop(), proposed_cost - current_cost))
    #         spl.reject_proposed()

    # for i in range(num_programs):
    #     cur_res = loaded_spls[i].current_cmp
    #     logger.debug(f"Sampler {i}: {cur_res.get_sound_prop() * 100:.2f}% {cur_res.get_unsolved_exact_prop() * 100:.2f}%")
    #     sorted_ls= sorted(neighbor_tfs[i], key=lambda x: x[2])
    #     for t in sorted_ls:
    #         logger.debug(f"{t[0]* 100:.3f}% {t[1]* 100:.3f}% {t[2]:.6f}")

    new_solution_set: SolutionSet = solution_set.construct_new_solution_set(
        candidates_sp,
        candidates_p,
        candidates_c,
        concrete_func,
        helper_funcs,
        num_unsound_candidates,
        ctx,
    )

    return new_solution_set
