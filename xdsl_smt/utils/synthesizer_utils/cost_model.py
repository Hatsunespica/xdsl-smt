import math
from typing import Callable

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult


def sound_and_precise_cost(res: EvalResult, get_max_dis: Callable[[int], int]) -> float:
    a = 1
    b = 16
    sound = res.get_sound_prop()
    dis = res.get_unsolved_dist_avg_norm(get_max_dis)
    return (a * (1 - sound) + b * dis) / (a + b)


def precise_cost(res: EvalResult, get_max_dis: Callable[[int], int]) -> float:
    a = 0
    b = 1
    sound = res.get_sound_prop()
    dis = res.get_unsolved_dist_avg_norm(get_max_dis)
    return (a * (1 - sound) + b * dis) / (a + b)


def abduction_cost(res: EvalResult, get_max_dis: Callable[[int], int]) -> float:
    a = 1
    b = 2
    sound = res.get_sound_prop()
    dis = res.get_unsolved_dist_avg_norm(get_max_dis)
    return (a * (1 - sound) + b * dis) / (a + b)


def decide(p: float, beta: float, current_cost: float, proposed_cost: float) -> bool:
    return beta * (current_cost - proposed_cost) > math.log(p)
