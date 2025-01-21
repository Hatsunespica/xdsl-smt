import random
from typing import Sequence, TypeVar

T = TypeVar("T")


class Random:
    def __init__(self, seed: int | None = None):
        if seed is not None:
            random.seed(seed)

    def random(self) -> float:
        return random.random()

    def choice(self, lst: Sequence[T]) -> T:
        return random.choice(lst)

    def randint(self, a: int, b: int) -> int:
        return random.randint(a, b)
