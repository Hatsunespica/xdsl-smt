from typing import Callable
from dataclasses import dataclass


@dataclass
class PerBitEvalResult:
    "The evaluation result of (a candidate transformer f MEET a set of sound transformer F) and the best transformer f_best"

    all_cases: int
    "The number of inputs"

    bitwidth: int
    "The bitwidth it evaluates on"

    sounds: int
    "The number of inputs on which (f MEET F) gets sound"

    exacts: int
    "The number of inputs on which (f MEET F) gets exact"

    dist: int
    r"dist(f,g) := \sum{a} d(f(a) /\ g(a), best(a))"

    base_dist: int
    r"base_dis(f,g) := \sum{a} d(g(a), best(a))"

    unsolved_cases: int
    "The number of unsolved inputs (F do not get exact)"

    unsolved_sounds: int
    "The number of unsolved inputs on which (f MEET F) gets sound"

    unsolved_exacts: int
    "The number of unsolved inputs on which (f MEET F) gets exact"

    unsolved_dist: int
    r"unsolved_dis(f,g) := \sum{a, g(a) is not exact} d(f(a) /\ g(a), best(a))"

    sound_dist: int
    r"sound_dis(f,g) := \sum{a, f(a) is sound} d(f(a) /\ g(a), best(a)) + \sum{a, f(a) is unsound} d(g(a), best(a))"

    def __str__(self):
        s = ""
        s += f"bw: {self.bitwidth:<3}"
        s += f"all: {self.all_cases:<6}"
        s += f"s: {self.sounds:<6}"
        s += f"e: {self.exacts:<6}"
        s += f"uall: {self.unsolved_cases:<6}"
        s += f"us: {self.unsolved_sounds:<6}"
        s += f"ue: {self.unsolved_exacts:<6}"
        s += f"dis: {self.dist:<6}"
        s += f"udis: {self.unsolved_dist:<6}"
        s += f"bdis: {self.base_dist:<6}"
        s += f"sdis: {self.sound_dist:<6}"
        return s

    def get_sound_prop(self) -> float:
        return self.sounds / self.all_cases

    def get_exact_prop(self) -> float:
        return self.exacts / self.all_cases


class EvalResult:
    per_bit: list[PerBitEvalResult]
    max_bit: int
    all_cases: int
    sounds: int
    exacts: int
    dist: int
    base_dist: int
    unsolved_cases: int
    unsolved_sounds: int
    unsolved_exacts: int
    unsolved_dist: int
    sound_dist: int

    def __init__(self, per_bit: list[PerBitEvalResult]):
        self.per_bit = per_bit
        self.max_bit = max(per_bit, key=lambda x: x.bitwidth).bitwidth
        self.all_cases = sum(res.all_cases for res in per_bit)
        self.sounds = sum(res.sounds for res in per_bit)
        self.exacts = sum(res.exacts for res in per_bit)
        self.dist = sum(res.dist for res in per_bit)
        self.base_dist = sum(res.base_dist for res in per_bit)
        self.sound_dist = sum(res.sound_dist for res in per_bit)
        self.unsolved_cases = sum(res.unsolved_cases for res in per_bit)
        self.unsolved_sounds = sum(res.unsolved_sounds for res in per_bit)
        self.unsolved_exacts = sum(res.unsolved_exacts for res in per_bit)
        self.unsolved_dist = sum(res.unsolved_dist for res in per_bit)

    def __str__(self):
        return "\n".join(str(res) for res in self.per_bit)

    def get_unsolved_cases(self) -> int:
        return self.unsolved_cases

    def get_unsolved_exacts(self) -> int:
        return self.unsolved_exacts

    def get_exacts(self) -> int:
        return self.exacts

    def get_dist(self) -> int:
        return self.dist

    def get_base_dist(self) -> int:
        return self.base_dist

    def get_sound_dist(self) -> int:
        return self.sound_dist

    def get_sound_prop(self) -> float:
        return self.sounds / self.all_cases

    def get_exact_prop(self) -> float:
        return self.exacts / self.all_cases

    def get_unsolved_exact_prop(self) -> float:
        return self.unsolved_exacts / self.unsolved_cases

    def get_unsolved_dist_avg_norm(self, get_max_dis: Callable[[int], int]) -> float:
        return (
            sum(res.unsolved_dist / get_max_dis(res.bitwidth) for res in self.per_bit)
            / self.unsolved_cases
        )

    def get_new_exact_prop(self) -> float:
        return self.unsolved_exacts / self.all_cases

    def is_sound(self):
        return self.sounds == self.all_cases

    def get_unsolved_dis_decrease(self):
        return self.base_dist - self.unsolved_dist

    def get_improve(self):
        greedy_by_dist = True
        if greedy_by_dist:
            return self.get_unsolved_dis_decrease()
        else:
            return self.unsolved_exacts

    def get_potential_improve(self):
        return self.base_dist - self.sound_dist


@dataclass
class HighPerBitRes:
    bitwidth: int
    num_samples: int
    ref_score: int
    synth_score_sum: int
    meet_score_sum: int
    num_bottoms: int


@dataclass
class HighBitRes:
    per_bit: list[HighPerBitRes]
