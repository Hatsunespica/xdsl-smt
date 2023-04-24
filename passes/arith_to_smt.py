from typing import cast
from xdsl.ir import Attribute, MLContext, OpResult, Operation, SSAValue
from xdsl.pattern_rewriter import (
    GreedyRewritePatternApplier,
    PatternRewriteWalker,
    PatternRewriter,
    RewritePattern,
    op_type_rewrite_pattern,
)
from xdsl.dialects.builtin import IntegerAttr, IntegerType, ModuleOp, FunctionType
from xdsl.dialects.func import FuncOp, Return
from xdsl.passes import ModulePass
from xdsl.utils.hints import isa

import dialects.smt_bitvector_dialect as bv_dialect
import dialects.arith_dialect as arith
from dialects.smt_bitvector_dialect import BitVectorType
from traits.smt_printer import SMTLibSort
from dialects.smt_utils_dialect import AnyPairType, FirstOp, PairOp, PairType, SecondOp
from dialects.smt_dialect import BoolType, ConstantBoolOp, DefineFunOp, ReturnOp, OrOp


def convert_type(type: Attribute) -> Attribute:
    """Convert a type to an SMT sort"""
    if isinstance(type, IntegerType):
        return BitVectorType(type.width)
    raise Exception("Cannot convert {type} attribute")


class IntegerConstantRewritePattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: arith.Constant, rewriter: PatternRewriter):
        if not isa(op.value, IntegerAttr[IntegerType]):
            raise Exception("Cannot convert constant of type that are not integer type")
        smt_op = bv_dialect.ConstantOp(op.value)
        rewriter.replace_matched_op(smt_op)


class OriRewritePattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: arith.Ori, rewriter: PatternRewriter):
        smt_op = bv_dialect.OrOp(op.lhs, op.rhs)
        rewriter.replace_matched_op(smt_op)


class ReturnPattern(RewritePattern):
    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: Return, rewriter: PatternRewriter):
        if len(op.arguments) != 1:
            raise Exception("Cannot convert functions with multiple results")
        smt_op = ReturnOp(op.arguments[0])
        rewriter.replace_matched_op(smt_op)


class FuncToSMTPattern(RewritePattern):
    """Convert func.func to an SMT formula"""

    @op_type_rewrite_pattern
    def match_and_rewrite(self, op: FuncOp, rewriter: PatternRewriter):
        """
        Convert a `func` function to an smt function.
        """
        # We only handle single-block regions for now
        if len(op.body.blocks) != 1:
            raise Exception("Cannot convert multi-block functions")
        if len(op.function_type.outputs.data) != 1:
            raise Exception("Cannot convert functions with multiple results")

        operand_types = [convert_type(input) for input in op.function_type.inputs.data]
        result_type = convert_type(op.function_type.outputs.data[0])

        # The SMT function replacing the func.func function
        smt_func = DefineFunOp.from_function_type(
            FunctionType.from_lists(operand_types, [result_type]), op.sym_name
        )

        # Replace the old arguments to the new ones
        for i, arg in enumerate(smt_func.body.blocks[0].args):
            op.body.blocks[0].args[i].replace_by(arg)

        # Move the operations to the SMT function
        ops = op.body.ops
        for body_op in ops:
            body_op.detach()
        smt_func.body.blocks[0].add_ops(ops)

        # Replace the arith function with the SMT one
        rewriter.replace_matched_op(smt_func, new_results=[])


class ArithToSMT(ModulePass):
    name = "arith-to-smt"

    def apply(self, ctx: MLContext, op: ModuleOp):
        walker = PatternRewriteWalker(
            GreedyRewritePatternApplier(
                [
                    IntegerConstantRewritePattern(),
                    OriRewritePattern(),
                    FuncToSMTPattern(),
                    ReturnPattern(),
                ]
            )
        )
        walker.rewrite_module(op)
