import math
from typing import Callable

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult


def general_cost(a: float, b: float, s: float, p: float) -> float:
    """
    General cost function that combines soundness and precision.
    """
    return (a * (1 - s) + b * (1 - p)) / (a + b)


def general_sound_and_dist_cost(a: float, b: float, res: EvalResult) -> float:
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist()
    return general_cost(a, b, sound, 1 - dis)


def more_sound(res: EvalResult) -> float:
    return general_sound_and_dist_cost(1, 2, res)


def only_precise(res: EvalResult) -> float:
    return general_sound_and_dist_cost(0, 1, res)


def less_sound(res: EvalResult) -> float:
    return general_sound_and_dist_cost(2, 1, res)


def sound_first(res: EvalResult) -> float:
    """
    cost(s, p) = ((1 - s) + 1) / 2, if unsound
               = (0 + (1 - p)) / 2, if sound
    """
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist() if sound == 1 else 1
    return general_cost(1, 1, sound, 1 - dis)


def must_sound(res: EvalResult) -> float:
    """
    cost(s, p) = 1, if unsound
               = 1 - p, if sound
    """
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist() if sound == 1 else 1
    return dis


def gradual_cost(
    cost0: Callable[[EvalResult], float], cost1: Callable[[EvalResult], float]
) -> Callable[[EvalResult, float], float]:
    """
    Returns a function that computes a gradual cost based on the result and a parameter t.
    The cost is a linear interpolation between cost0 and cost1 based on t.
    """

    def cost(res: EvalResult, t: float) -> float:
        return (1 - t) * cost0(res) + t * cost1(res)

    return cost


def non_gradual_cost(
    cost0: Callable[[EvalResult], float],
) -> Callable[[EvalResult, float], float]:
    return lambda res, t: cost0(res)


sound_and_precise_cost = non_gradual_cost(more_sound)
precise_cost = non_gradual_cost(only_precise)
abduction_cost = non_gradual_cost(less_sound)

# sound_and_precise_cost = gradual_cost(more_sound, must_sound)
# precise_cost = non_gradual_cost(only_precise)
# abduction_cost = gradual_cost(less_sound, must_sound)


def decide(p: float, beta: float, current_cost: float, proposed_cost: float) -> bool:
    return beta * (current_cost - proposed_cost) > math.log(p)
