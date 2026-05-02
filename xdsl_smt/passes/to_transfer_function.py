from xdsl.dialects.builtin import ModuleOp
from xdsl.ir import Operation, Attribute
from xdsl.context import Context
from xdsl.passes import ModulePass
from xdsl.pattern_rewriter import PatternRewriteWalker, PatternRewriter, RewritePattern
from xdsl_smt.traits.effects import Pure
from xdsl_smt.dialects.transfer import TransIntegerType, AbstractValueType
from xdsl.dialects.func import CallOp

def toKbType(typ: Attribute)->Attribute:
    if isinstance(typ, TransIntegerType):
        return AbstractValueType([typ,typ])
    return typ

def getFuncName(name:str):
    idx = name.find(".")
    return name[idx+1:]+"_solution"

def isTransferOp(op:Operation):
    return op.name.startswith("transfer")

def isConstantOp(op:Operation):
    return op.name=="transfer.constant" or op.name=="transfer.get_bit_width"

def getFuncCall(op: Operation):
    if op.name.startswith("transfer"):
        if not isConstantOp(op):
            new_name = getFuncName(op.name)
            callOp = CallOp(new_name, op.operands, [toKbType(op.results[0].type)])
        else:
            new_name = 'constant_to_kb'
            callOp = CallOp(new_name, op.results, [toKbType(op.results[0].type)])
        return callOp

    return op

class ToTransferFunctionPattern(RewritePattern):
    def match_and_rewrite(self, op: Operation, rewriter: PatternRewriter):
        if isTransferOp(op):
            callOp = getFuncCall(op)
            if callOp!=op:
                if isConstantOp(op):
                    rewriter.insert_op_after_matched_op(callOp)
                    op.results[0].replace_by(callOp.results[0])
                    callOp.operands[0]=op.results[0]
                else:
                    rewriter.replace_matched_op(callOp)
                return
        rewriter.has_done_action=True


class ToTransferFunction(ModulePass):
    name = "to_transfer"

    def apply(self, ctx: Context, op: ModuleOp):
        walker = PatternRewriteWalker(ToTransferFunctionPattern(), walk_reverse=True, apply_recursively=False)
        walker.rewrite_module(op)
