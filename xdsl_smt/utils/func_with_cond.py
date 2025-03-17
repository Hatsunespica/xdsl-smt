from typing import Callable

from xdsl.dialects.func import FuncOp


class FuncWithCond:
    func: FuncOp
    cond: FuncOp | None

    def __init__(self, func: FuncOp, cond: FuncOp | None = None):
        self.func = func
        self.cond = cond

    def to_str(self, eliminate_dead_code: Callable[[FuncOp], FuncOp]):
        cond_str = (
            "True\n" if self.cond is None else str(eliminate_dead_code(self.cond))
        )
        return f"Cond:\n{cond_str}\nFunc:{str(eliminate_dead_code(self.func))}"
