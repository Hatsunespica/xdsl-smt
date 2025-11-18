from __future__ import annotations
from typing import Callable
from egglog import i64Like, StringLike, EGraph, Expr, method, rewrite, ruleset, vars_
from xdsl.dialects.func import FuncOp
from xdsl.ir.core import BlockArgument

from xdsl_smt.dialects.transfer import GetAllOnesOp, GetOp, MakeOp, Constant
from xdsl.ir import Operation, OpResult
from xdsl_smt.egraph_rewriter.datatypes import BV, mlir_op_to_egraph_op, gen_ruleset


class ExprBuilder:
    func: FuncOp
    op_to_expr: dict[Operation, Expr]
    arg_index: dict[BlockArgument, int]
    ret_exprs: list[Expr]

    def __init__(self, _func: FuncOp):
        self.func = _func
        self.op_to_expr = {}
        self.ret_exprs = []
        self.arg_index = {}

    def create_arg_name(self, op: BlockArgument, index: int) -> str:
        return f"arg{self.arg_index[op]}_{index}"

    def build_expr(self):
        block = self.func.body.blocks[0]

        for i, arg in enumerate(block.args):
            self.arg_index[arg] = i

        for op in block.ops:
            if isinstance(op, GetOp):
                arg_name = self.create_arg_name(op.operands[0], op.index.value.data)
                self.op_to_expr[op] = BV.var(arg_name)

            if isinstance(op, MakeOp):
                for operand in op.operands:
                    self.ret_exprs.append(self.op_to_expr[operand.owner])
                return

            if isinstance(op, Constant):
                const_value = op.value.value.data
                self.op_to_expr[op] = BV(const_value)

            if isinstance(op, GetAllOnesOp):
                self.op_to_expr[op] = BV(-1)

            if type(op) in mlir_op_to_egraph_op:
                egraph_op = mlir_op_to_egraph_op[type(op)]
                expr_operands = [
                    self.op_to_expr[operand.owner] for operand in op.operands
                ]
                # print("operands:", expr_operands, "egraph_op:", egraph_op)
                self.op_to_expr[op] = egraph_op(*expr_operands)


def simplify_term(expr: Expr) -> tuple[Expr, int, int]:
    egraph = EGraph()
    rules = gen_ruleset()
    expr_to_simplify = egraph.let("expr_to_simplify", expr)
    _, previous_cost = egraph.extract(expr_to_simplify, include_cost=True)
    # print(f"\tExpr: {expr}")
    egraph.run(8, ruleset=rules)
    new_expr, new_cost = egraph.extract(expr_to_simplify, include_cost=True)
    # print(f"\tNew Expr: {new_expr}")
    # print(f"Size: {previous_cost} -> {new_cost}")
    return new_expr, previous_cost, new_cost
