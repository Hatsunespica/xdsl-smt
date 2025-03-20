from dataclasses import dataclass
from typing import Callable

from xdsl.dialects.func import FuncOp


@dataclass
class FunctionWithCondition:
    """
    Class for a transfer function f in the form of "f(a) := if (cond) then func(a) else Top"
    """

    func: FuncOp
    cond: FuncOp | None = None

    def to_str(self, eliminate_dead_code: Callable[[FuncOp], FuncOp]):
        cond_str = (
            "True\n" if self.cond is None else str(eliminate_dead_code(self.cond))
        )
        return f"Cond:\n{cond_str}\nFunc:{str(eliminate_dead_code(self.func))}"
