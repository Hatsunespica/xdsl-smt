import math


# def compute_cost(soundness: float, precision: float) -> float:
#     a: float = 1
#     b: float = 2
#     return (a * (1 - soundness) + b * (1 - precision)) / (a + b)


def decide(p: float, beta: float, current_cost: float, proposed_cost: float) -> bool:
    # return math.exp(-16 * (proposed_cost - current_cost))

    # return True

    return beta * (current_cost - proposed_cost) > math.log(p)
