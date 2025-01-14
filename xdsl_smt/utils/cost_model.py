def compute_cost(soundness: float, precision: float) -> float:
    if soundness == 1:
        return 1 - precision
    else:
        return 2 - soundness
    # return 1 / (soundness + 1e-3)


def compute_accept_rate(current_cost: float, proposed_cost: float) -> float:
    # return math.exp(-16 * (proposed_cost - current_cost))
    return 1 if proposed_cost <= current_cost else 0
