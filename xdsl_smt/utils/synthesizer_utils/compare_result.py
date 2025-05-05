from typing import Callable


class PerBitEvalResult:
    """The evaluation result of (a candidate transformer f MEET a set of sound transformer F) and the best transformer f_best"""

    all_cases: int
    """The number of inputs"""

    bitwidth: int
    """The bitwidth it evaluates on"""

    sounds: int
    """The number of inputs on which (f MEET F) gets sound"""

    exacts: int
    """The number of inputs on which (f MEET F) gets exact"""

    dist: int
    """The sum of edit distance between the outputs of (f MEET F) and the f_best """

    base_dist: int
    """The sum of edit distance between the outputs of F and the f_best"""

    unsolved_cases: int
    """The number of unsolved inputs (F do not get exact)"""

    unsolved_sounds: int
    """The number of unsolved inputs on which (f MEET F) gets sound"""

    unsolved_exacts: int
    """The number of unsolved inputs on which (f MEET F) gets exact"""

    unsolved_dist: int
    """The sum of edit distance between the outputs of (f MEET F) and the f_best on unsolved inputs"""

    greedy_by_dist = True  # default
    """If True, the improvement is calculated by the decrease of distance. Otherwise, it is calculated by the number of new exacts"""

    def __init__(
        self,
        all_cases: int,
        sounds: int,
        exacts: int,
        edit_dis: int,
        unsolved_cases: int,
        unsolved_sounds: int,
        unsolved_exacts: int,
        unsolved_edit_dis: int,
        base_edit_dis: int,
        bitwidth: int,
    ):
        self.all_cases = all_cases
        self.sounds = sounds
        self.exacts = exacts
        self.dist = edit_dis
        self.unsolved_cases = unsolved_cases
        self.unsolved_sounds = unsolved_sounds
        self.unsolved_exacts = unsolved_exacts
        self.unsolved_dist = unsolved_edit_dis
        self.base_dist = base_edit_dis
        self.bitwidth = bitwidth

    def __str__(self):
        return f"all: {self.all_cases}\ts: {self.sounds}\te: {self.exacts}\tp: {self.dist}\tunsolved:{self.unsolved_cases}\tus: {self.unsolved_sounds}\tue: {self.unsolved_exacts}\tup: {self.unsolved_dist}\tbasep: {self.base_dist}"

    def get_sound_prop(self) -> float:
        return self.sounds / self.all_cases

    def get_exact_prop(self) -> float:
        return self.exacts / self.all_cases

    def get_unsolved_exact_prop(self) -> float:
        return self.unsolved_exacts / self.unsolved_cases

    def get_unsolved_dist_avg(self) -> float:
        return self.unsolved_dist / self.unsolved_cases

    # def get_unsolved_dist_avg_norm(self) -> float:
    #     return self.unsolved_dist / (self.unsolved_cases * self.MAX_DIS)

    def get_new_exact_prop(self) -> float:
        return self.unsolved_exacts / self.all_cases

    def is_sound(self):
        return self.sounds == self.all_cases

    def get_unsolved_dis_decrease(self):
        return self.base_dist - self.unsolved_dist

    def get_improve(self):
        if PerBitEvalResult.greedy_by_dist:
            return self.get_unsolved_dis_decrease()
        else:
            return self.unsolved_exacts


class EvalResult:
    per_bit: dict[int, PerBitEvalResult]
    max_bit: int
    get_max_dis: Callable[[int], int] = lambda x: 0

    def __init__(self, per_bit: dict[int, PerBitEvalResult]):
        self.per_bit = per_bit
        self.max_bit = max(per_bit.keys())

    def __str__(self):
        return "\n".join(f"bw: {bw}\t{res}" for bw, res in self.per_bit.items())

    def get_unsolved_cases(self) -> int:
        return self.per_bit[self.max_bit].unsolved_cases

    def get_unsolved_exacts(self) -> int:
        return self.per_bit[self.max_bit].unsolved_exacts

    def get_exacts(self) -> int:
        return self.per_bit[self.max_bit].exacts

    def get_dist(self) -> int:
        return self.per_bit[self.max_bit].dist

    def get_base_dist(self) -> int:
        return self.per_bit[self.max_bit].base_dist

    def get_sound_prop(self) -> float:
        return self.per_bit[self.max_bit].get_sound_prop()

    def get_exact_prop(self) -> float:
        return self.per_bit[self.max_bit].get_exact_prop()

    def get_unsolved_exact_prop(self) -> float:
        return self.per_bit[self.max_bit].get_unsolved_exact_prop()

    def get_unsolved_dist_avg(self) -> float:
        return self.per_bit[self.max_bit].get_unsolved_dist_avg()

    def get_unsolved_dist_avg_norm(self) -> float:
        return self.per_bit[
            self.max_bit
        ].get_unsolved_dist_avg() / EvalResult.get_max_dis(self.max_bit)

    def get_new_exact_prop(self) -> float:
        return self.per_bit[self.max_bit].get_new_exact_prop()

    def is_sound(self):
        return self.per_bit[self.max_bit].is_sound()

    def get_unsolved_dis_decrease(self):
        return self.per_bit[self.max_bit].get_unsolved_dis_decrease()

    def get_improve(self):
        return self.per_bit[self.max_bit].get_improve()
