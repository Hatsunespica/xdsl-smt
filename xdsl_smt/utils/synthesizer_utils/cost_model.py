import math

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult


def general_cost(a: float, b: float, s: float, p: float) -> float:
    return (a * (1 - s) + b * (1 - p)) / (a + b)


def general_sound_and_dist_cost(a: float, b: float, res: EvalResult) -> float:
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist()
    return general_cost(a, b, sound, 1 - dis)


def _more_sound(res: EvalResult) -> float:
    return general_sound_and_dist_cost(1, 2, res)


def _only_precise(res: EvalResult) -> float:
    return general_sound_and_dist_cost(0, 1, res)


def _less_sound(res: EvalResult) -> float:
    return general_sound_and_dist_cost(2, 1, res)


def _sound_first(res: EvalResult) -> float:
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist() if sound == 1 else 1
    return general_cost(1, 1, sound, 1 - dis)


sound_and_precise_cost = _more_sound
precise_cost = _only_precise
abduction_cost = _less_sound


def decide(p: float, beta: float, current_cost: float, proposed_cost: float) -> bool:
    return beta * (current_cost - proposed_cost) > math.log(p)
