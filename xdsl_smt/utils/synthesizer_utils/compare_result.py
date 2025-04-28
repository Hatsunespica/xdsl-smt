class CompareResult:
    """The comparison result of (a candidate transformer f MEET a set of sound transformer F) and the best transformer f_best"""

    all_cases: int
    """The number of inputs"""

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

    MAX_DIS: int = 0

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

    @classmethod
    def set_max_dis(cls, max_dis: int):
        assert cls.MAX_DIS == 0, "MAX_DIS has been set before"
        assert max_dis > 0, "MAX_DIS should be positive"
        cls.MAX_DIS = max_dis

    def get_sound_prop(self) -> float:
        return self.sounds / self.all_cases

    def get_exact_prop(self) -> float:
        return self.exacts / self.all_cases

    def get_unsolved_sound_prop(self) -> float:
        return self.unsolved_sounds / self.unsolved_cases

    def get_unsolved_exact_prop(self) -> float:
        return self.unsolved_exacts / self.unsolved_cases

    def get_dist_avg(self) -> float:
        return self.dist / self.all_cases

    def get_unsolved_dist_avg(self) -> float:
        return self.unsolved_dist / self.unsolved_cases

    def get_unsolved_dist_avg_norm(self) -> float:
        return self.unsolved_dist / (self.unsolved_cases * self.MAX_DIS)

    def get_new_exact_prop(self) -> float:
        return self.unsolved_exacts / self.all_cases

    def is_sound(self):
        return self.sounds == self.all_cases

    def get_unsolved_dis_decrease(self):
        return self.base_dist - self.unsolved_dist

    def get_improve(self):
        if CompareResult.greedy_by_dist:
            return self.get_unsolved_dis_decrease()
        else:
            return self.unsolved_exacts
