import math

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult


def sound_and_precise_cost(res: EvalResult) -> float:
    a = 1
    b = 16
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist()
    # if dis == 1:
    #     return 1
    return (a * (1 - sound) + b * dis) / (a + b)


def precise_cost(res: EvalResult) -> float:
    a = 0
    b = 1
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist()
    # if dis == 1:
    #     return 1
    return (a * (1 - sound) + b * dis) / (a + b)


def abduction_cost(res: EvalResult) -> float:
    a = 1
    b = 2
    sound = res.get_sound_prop()
    dis = res.get_sound_dist() / res.get_base_dist()
    # if dis == 1:
    #     return 1
    return (a * (1 - sound) + b * dis) / (a + b)


def decide(p: float, beta: float, current_cost: float, proposed_cost: float) -> bool:
    return beta * (current_cost - proposed_cost) > math.log(p)
