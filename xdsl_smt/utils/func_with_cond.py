from typing import Callable

from xdsl.dialects.func import FuncOp


class FuncWithCond:
    func: FuncOp
    cond: FuncOp | None
    def __init__(self, func: FuncOp, cond: FuncOp | None = None):
        self.func= func
        self.cond = cond

    def to_str(self, eliminate_dead_code: Callable[[FuncOp], FuncOp]):
        cond_str = "True\n" if self.cond is None else str(eliminate_dead_code(self.cond))
        return f"Cond:\n{cond_str}\nFunc:{str(eliminate_dead_code(self.func))}"

#     def rename(self, name: str, lower_to_cpp: Callable[[FuncOp], str], eliminate_dead_code: Callable[[FuncOp], FuncOp]):
#         self.mlir.sym_name = StringAttr(name)
#         self.cpp = lower_to_cpp(eliminate_dead_code(self.mlir))
#
# def to_mlirs(funcs: list[FuncWithCpp]) -> list[FuncOp]:
#     return [x.mlir for x in funcs]
#
# def to_names(funcs: list[FuncWithCpp]) -> list[str]:
#     return [x.mlir.sym_name.data for x in funcs]
#
# def to_srcs(funcs: list[FuncWithCpp]) -> list[str]:
#     return [x.cpp for x in funcs]
#
# def to_cond_names(funcs: list[FuncWithCpp | None]) -> list[str | None]:
#     return [None if x is None else x.mlir.sym_name for x in funcs]
#
# def to_cond_srcs(funcs: list[FuncWithCpp | None]) -> list[str | None]:
#     return [None if x is None else x.cpp for x in funcs]
