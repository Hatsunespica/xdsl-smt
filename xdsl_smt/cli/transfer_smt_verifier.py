#!/usr/bin/env python3

import argparse
import subprocess

from xdsl.ir import MLContext
from xdsl.parser import Parser

from io import StringIO
from ..dialects.smt_dialect import (
    SMTDialect,
    DefineFunOp,
    DeclareConstOp,
    CallOp,
    AssertOp,
    CheckSatOp,
    EqOp,
    ConstantBoolOp,
    ImpliesOp,
    ForallOp,
    AndOp,
    YieldOp,
)
from ..dialects.smt_bitvector_dialect import SMTBitVectorDialect, ConstantOp
from ..dialects.smt_utils_dialect import FirstOp, PairOp
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl.ir.core import BlockArgument
from xdsl.dialects.builtin import (
    Builtin,
    ModuleOp,
    IntegerAttr,
    IntegerType,
    i1,
    FunctionType,
    Region,
    Block,
)
from xdsl.dialects.func import Func
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith
from ..passes.transfer_inline import FunctionCallInline
import xdsl.dialects.comb as comb
from ..utils.trans_interpreter_smt import *
from ..passes.lower_to_smt.lower_to_smt import LowerToSMT, integer_poison_type_lowerer
from ..passes.lower_to_smt.transfer_to_smt import (
    abstract_value_type_lowerer,
    transfer_integer_type_lowerer,
)
from ..passes.lower_to_smt import (
    func_to_smt_patterns,
)
from ..passes.transfer_unroll_loop import UnrollTransferLoop
from xdsl_smt.semantics import transfer_semantics
from ..traits.smt_printer import print_to_smtlib
from xdsl_smt.passes.lower_pairs import LowerPairs
from xdsl_smt.passes.canonicalize_smt import CanonicalizeSMT
from xdsl_smt.semantics.arith_semantics import arith_semantics
from xdsl_smt.semantics.transfer_semantics import transfer_semantics
from xdsl_smt.semantics.comb_semantics import comb_semantics
import sys as sys


def register_all_arguments(arg_parser: argparse.ArgumentParser):
    arg_parser.add_argument(
        "transfer_functions", type=str, nargs="?", help="path to the transfer functions"
    )


def parse_file(ctx, file: str | None) -> Operation:
    if file is None:
        f = sys.stdin
    else:
        f = open(file)

    parser = Parser(ctx, f.read(), file)
    module = parser.parse_op()
    return module


KEY_NEED_VERIFY = "builtin.NEED_VERIFY"
MAXIMAL_VERIFIED_BITS = 8


def solveVectorWidth():
    return list(range(4, 5))


def verify_pattern(ctx: MLContext, op: ModuleOp) -> bool:
    cloned_op = op.clone()
    # PDLToSMT().apply(ctx, cloned_op)
    # print_to_smtlib(cloned_op,sys.stdout)
    LowerPairs().apply(ctx, cloned_op)
    CanonicalizeSMT().apply(ctx, cloned_op)
    #print(cloned_op)
    stream = StringIO()
    print_to_smtlib(cloned_op, stream)
    # print_to_smtlib(cloned_op, sys.stdout)
    #print(stream.getvalue())

    res = subprocess.run(
        ["z3", "-in"],
        capture_output=True,
        input=stream.getvalue(),
        text=True,
    )
    if res.returncode != 0:
        raise Exception(res.stderr)
    return "unsat" in res.stdout


def basic_constraint_check(abstract_func: DefineFunOp, get_constraint: DefineFunOp):
    abstract_type = get_constraint.body.block.args[0].type
    arg_constant: list[DeclareConstOp] = []
    arg_constraints: list[CallOp] = []
    arg_constraints_first: list[FirstOp] = []
    for arg in abstract_func.body.block.args:
        arg_constant.append(DeclareConstOp(arg.type))
        if arg.type == abstract_type:
            arg_constraints.append(
                CallOp.get(get_constraint.results[0], [arg_constant[-1].results[0]])
            )
            arg_constraints_first.append(FirstOp(arg_constraints[-1].results[0]))
    assert len(arg_constant) != 0

    abstract_result = CallOp.get(
        abstract_func.results[0], [op.results[0] for op in arg_constant]
    )
    result_constraint = CallOp.get(
        get_constraint.results[0], [abstract_result.results[0]]
    )
    result_constraint_first = FirstOp(result_constraint.results[0])

    constant_bv_0 = ConstantOp(0, 1)
    constant_bv_1 = ConstantOp(1, 1)

    eq_ops: list[EqOp] = []
    assert_ops: list[AssertOp] = []

    for c in arg_constraints_first:
        eq_ops.append(EqOp(constant_bv_1.results[0], c.results[0]))
        assert_ops.append(AssertOp(eq_ops[-1].results[0]))

    eq_ops.append(EqOp(constant_bv_0.results[0], result_constraint_first.results[0]))
    assert_ops.append(AssertOp(eq_ops[-1].results[0]))

    return (
        arg_constant
        + arg_constraints
        + arg_constraints_first
        + [abstract_result, result_constraint, result_constraint_first]
        + [constant_bv_1, constant_bv_0]
        + eq_ops
        + assert_ops
        + [CheckSatOp()]
    )


def test_abs_inline_check(
    abstract_func: DefineFunOp,
):
    arg_constant: list[DeclareConstOp] = []
    for arg in abstract_func.body.block.args:
        arg_constant.append(DeclareConstOp(arg.type))
    assert len(arg_constant) != 0

    abstract_result = CallOp.get(
        abstract_func.results[0], [op.results[0] for op in arg_constant]
    )
    return arg_constant + [abstract_result]


def soundness_check(
    abstract_func: DefineFunOp,
    concrete_func: DefineFunOp,
    get_constraint: DefineFunOp,
    get_inst_constraint: DefineFunOp,
    op_constraint: DefineFunOp,
):
    abstract_type = get_constraint.body.block.args[0].type
    instance_type = concrete_func.body.block.args[1].type.first
    arg_constant: list[DeclareConstOp] = []
    inst_constant: list[DeclareConstOp] = []
    arg_constraints: list[CallOp] = []
    inst_constraints: list[CallOp] = []
    arg_constraints_first: list[FirstOp] = []
    inst_constraints_first: list[FirstOp] = []

    for arg in abstract_func.body.block.args:
        arg_constant.append(DeclareConstOp(arg.type))
        if arg.type == abstract_type:
            arg_constraints.append(
                CallOp.get(get_constraint.results[0], [arg_constant[-1].results[0]])
            )
            arg_constraints_first.append(FirstOp(arg_constraints[-1].results[0]))

            inst_constant.append(DeclareConstOp(instance_type))
            inst_constraints.append(
                CallOp.get(
                    get_inst_constraint.results[0],
                    [arg_constant[-1].results[0], inst_constant[-1].results[0]],
                )
            )
            inst_constraints_first.append(FirstOp(inst_constraints[-1].results[0]))
        else:
            inst_constant.append(arg_constant[-1])

    assert len(arg_constant) != 0

    abstract_result = CallOp.get(
        abstract_func.results[0], [op.results[0] for op in arg_constant]
    )
    constant_false = ConstantBoolOp(False)
    inst_constant_pair = [
        PairOp(op.results[0], constant_false.res) for op in inst_constant
    ]
    inst_result_pair = CallOp.get(
        concrete_func.results[0], [op.results[0] for op in inst_constant_pair]
    )
    inst_result = FirstOp(inst_result_pair.res)
    inst_result_constraint = CallOp.get(
        get_inst_constraint.results[0],
        [abstract_result.results[0], inst_result.results[0]],
    )
    inst_result_constraint_first = FirstOp(inst_result_constraint.results[0])

    constant_bv_0 = ConstantOp(0, 1)
    constant_bv_1 = ConstantOp(1, 1)

    # consider op constraint
    op_constraint_list = []
    if op_constraint is not None:
        op_constraint_result = CallOp.get(op_constraint.results[0], inst_constant)
        op_constraint_result_first = FirstOp(op_constraint_result.res)
        op_constraint_eq = EqOp(constant_bv_1.res, op_constraint_result_first.res)
        op_constraint_assert = AssertOp(op_constraint_eq.res)
        op_constraint_list = [
            op_constraint_result,
            op_constraint_result_first,
            op_constraint_eq,
            op_constraint_assert,
        ]

    arg_constant.append(DeclareConstOp(abstract_type))
    inst_constant.append(DeclareConstOp(instance_type))

    eq_ops: list[EqOp] = []
    assert_ops: list[AssertOp] = []

    eq_ops.append(EqOp(arg_constant[-1].res, abstract_result.res))
    assert_ops.append(AssertOp(eq_ops[-1].results[0]))
    eq_ops.append(EqOp(inst_constant[-1].res, inst_result.res))
    assert_ops.append(AssertOp(eq_ops[-1].results[0]))

    for c in arg_constraints_first:
        eq_ops.append(EqOp(constant_bv_1.results[0], c.results[0]))
        assert_ops.append(AssertOp(eq_ops[-1].results[0]))

    for c in inst_constraints_first:
        eq_ops.append(EqOp(constant_bv_1.results[0], c.results[0]))
        assert_ops.append(AssertOp(eq_ops[-1].results[0]))
    eq_ops.append(
        EqOp(constant_bv_0.results[0], inst_result_constraint_first.results[0])
    )
    assert_ops.append(AssertOp(eq_ops[-1].results[0]))

    return (
        arg_constant
        + inst_constant
        + arg_constraints
        + inst_constraints
        + arg_constraints_first
        + inst_constraints_first
        + [
            abstract_result,
            constant_false,
        ]
        + inst_constant_pair
        + [
            inst_result_pair,
            inst_result,
            inst_result_constraint,
            inst_result_constraint_first,
        ]
        + [constant_bv_1, constant_bv_0]
        + op_constraint_list
        + eq_ops
        + assert_ops
        + [CheckSatOp()]
    )


def compress_and_op(lst):
    if len(lst) == 0:
        assert False and "cannot compress lst with size 0 to an AndOp"
    elif len(lst) == 1:
        return (lst[0].res, [])
    else:
        new_ops: list[AndOp] = [AndOp(lst[0].results[0], lst[1].results[0])]
        for i in range(2, len(lst)):
            new_ops.append(AndOp(new_ops[-1].res, lst[i].results[0]))
        return (new_ops[-1].res, new_ops)


def precision_check(
    abstract_func: DefineFunOp,
    concrete_func: DefineFunOp,
    get_constraint: DefineFunOp,
    get_inst_constraint: DefineFunOp,
    op_constraint: DefineFunOp,
):
    abstract_type = get_constraint.body.block.args[0].type
    instance_type = concrete_func.body.block.args[1].type.first
    arg_constant: list[DeclareConstOp] = []
    inst_constant: list[BlockArgument] = []

    c_constant = DeclareConstOp(abstract_type)
    c_constraints = CallOp.get(get_constraint.results[0], [c_constant.results[0]])
    c_constraints_first = FirstOp(c_constraints.res)

    arg_constraints: list[CallOp] = []
    inst_constraints: list[CallOp] = []
    arg_constraints_first: list[FirstOp] = []
    inst_constraints_first: list[FirstOp] = []

    constant_bv_0 = ConstantOp(0, 1)
    constant_bv_1 = ConstantOp(1, 1)

    abs_eq_ops: list[EqOp] = []
    assert_ops: list[AssertOp] = []
    inst_eq_ops: list[EqOp] = []

    # ForAll([arg0inst, arg1inst],
    #        Implies(And(getInstanceConstraint(arg0inst, arg0field0, arg0field1),
    #                    getInstanceConstraint(arg1inst, arg1field0, arg1field1)),
    #                getInstanceConstraint(concrete_op(arg0inst, arg1inst), cfield0, cfield1)))
    # This constraint is called cfiled constraint
    forall_cfield_constraint_block = Block()

    for arg in abstract_func.body.block.args:
        arg_constant.append(DeclareConstOp(arg.type))
        if arg.type == abstract_type:
            arg_constraints.append(
                CallOp.get(get_constraint.results[0], [arg_constant[-1].results[0]])
            )
            arg_constraints_first.append(FirstOp(arg_constraints[-1].results[0]))

            forall_cfield_constraint_block.insert_arg(
                instance_type, len(forall_cfield_constraint_block.args)
            )
            inst_constant.append(forall_cfield_constraint_block.args[-1])
            inst_constraints.append(
                CallOp.get(
                    get_inst_constraint.results[0],
                    [arg_constant[-1].results[0], inst_constant[-1]],
                )
            )
            inst_constraints_first.append(FirstOp(inst_constraints[-1].results[0]))
        else:
            forall_cfield_constraint_block.insert_arg(
                arg_constant[-1].res.type, len(forall_cfield_constraint_block.args)
            )

    assert len(arg_constant) != 0
    forall_cfield_constraint_block.add_ops(inst_constraints + inst_constraints_first)

    for c in arg_constraints_first:
        abs_eq_ops.append(EqOp(constant_bv_1.results[0], c.results[0]))
        assert_ops.append(AssertOp(abs_eq_ops[-1].results[0]))
    # handle c_constant
    abs_eq_ops.append(EqOp(constant_bv_1.res, c_constraints_first.res))
    assert_ops.append(AssertOp(abs_eq_ops[-1].results[0]))

    constant_false = ConstantBoolOp(False)
    inst_constant_pair = [PairOp(inst, constant_false.res) for inst in inst_constant]
    inst_result_pair = CallOp.get(
        concrete_func.results[0], [op.results[0] for op in inst_constant_pair]
    )
    # concrete_op(arg0inst, arg1inst)
    inst_result = FirstOp(inst_result_pair.res)
    # getInstanceConstraint(concrete_op(arg0inst, arg1inst), cfield0, cfield1))
    inst_result_constraint = CallOp.get(
        get_inst_constraint.results[0],
        [c_constant.res, inst_result.results[0]],
    )
    inst_result_constraint_first = FirstOp(inst_result_constraint.results[0])
    inst_result_constraint_first_eq = EqOp(
        inst_result_constraint_first.res, constant_bv_1.res
    )
    forall_cfield_constraint_block.add_ops(
        [constant_false]
        + inst_constant_pair
        + [
            inst_result_pair,
            inst_result,
            inst_result_constraint,
            inst_result_constraint_first,
            inst_result_constraint_first_eq,
        ]
    )

    for c in inst_constraints_first:
        inst_eq_ops.append(EqOp(constant_bv_1.results[0], c.results[0]))

    # consider op constraint
    op_constraint_list = []
    if op_constraint is not None:
        op_constraint_result = CallOp.get(op_constraint.results[0], inst_constant)
        op_constraint_result_first = FirstOp(op_constraint_result.res)
        op_constraint_eq = EqOp(constant_bv_1.res, op_constraint_result_first.res)
        op_constraint_assert = AssertOp(op_constraint_eq.res)
        op_constraint_list = [
            op_constraint_result,
            op_constraint_result_first,
            op_constraint_eq,
            op_constraint_assert,
        ]
        and_res, new_and_ops = compress_and_op(inst_eq_ops + [op_constraint_eq])
    else:
        and_res, new_and_ops = compress_and_op(inst_eq_ops)

    forall_cfield_constraint_block.add_ops(
        inst_eq_ops + op_constraint_list + new_and_ops
    )

    forall_cfield_constraint_implies_op = ImpliesOp(
        and_res, inst_result_constraint_first_eq.res
    )
    forall_cfield_constraint_block.add_ops(
        [
            forall_cfield_constraint_implies_op,
            YieldOp(forall_cfield_constraint_implies_op),
        ]
    )
    cfiled_constraint = ForallOp.from_variables(
        [inst_constant], Region(forall_cfield_constraint_block)
    )
    assert_ops.append(AssertOp(cfiled_constraint.res))

    # ForAll([cinst], Implies(getInstanceConstraint(cinst, cfield0, cfield1), getInstanceConstraint(cinst, abs_res[0], abs_res[1])))
    # This constraint is called cinst_constraint
    abstract_result = CallOp.get(
        abstract_func.results[0], [op.results[0] for op in arg_constant]
    )

    def get_cinst_constraint_ops(
        cinst: BlockArgument,
        cfield: DeclareConstOp,
        abs_res: CallOp,
        get_inst_constraint: DefineFunOp,
    ) -> list[Operation]:
        cinst_in_c_constraint = CallOp.get(
            get_inst_constraint.results[0],
            [cfield.res, cinst],
        )
        cinst_in_c_constraint_first = FirstOp(cinst_in_c_constraint.results[0])
        cinst_in_abs_res_constraint = CallOp.get(
            get_inst_constraint.results[0],
            [abs_res.res, cinst],
        )
        cinst_in_abs_res_constraint_first = FirstOp(cinst_in_abs_res_constraint.res)
        cinst_in_c_constraint_first_eq = EqOp(
            cinst_in_c_constraint_first.res, constant_bv_1.res
        )
        cinst_in_abs_res_constraint_first_eq = EqOp(
            cinst_in_abs_res_constraint_first.res, constant_bv_1.res
        )
        implies_op = ImpliesOp(
            cinst_in_c_constraint_first_eq.res, cinst_in_abs_res_constraint_first_eq.res
        )
        yield_op = YieldOp(implies_op.res)
        return [
            cinst_in_c_constraint,
            cinst_in_c_constraint_first,
            cinst_in_abs_res_constraint,
            cinst_in_abs_res_constraint_first,
            cinst_in_c_constraint_first_eq,
            cinst_in_abs_res_constraint_first_eq,
            implies_op,
            yield_op,
        ]

    forall_cinst_constraint_block = Block()
    forall_cinst_constraint_block.insert_arg(instance_type, 0)
    c_inst = forall_cinst_constraint_block.args[0]
    forall_cinst_constraint_block.add_ops(
        get_cinst_constraint_ops(
            c_inst, c_constant, abstract_result, get_inst_constraint
        )
    )

    cinst_constraint = ForallOp.from_variables(
        [instance_type], Region(forall_cinst_constraint_block)
    )
    assert_ops.append(AssertOp(cinst_constraint.res))

    # And(Not(getInstanceConstraint(abs_resInst, cfield0, cfield1)), getInstanceConstraint(abs_resInst, abs_res[0], abs_res[1]))
    # find an instance that is not in c but in abs_resInst
    abstract_result_inst = DeclareConstOp(instance_type)
    abstract_result_inst_constraint = CallOp.get(
        get_inst_constraint.results[0],
        [abstract_result.results[0], abstract_result_inst.results[0]],
    )
    abstract_result_inst_constraint_first = FirstOp(
        abstract_result_inst_constraint.results[0]
    )
    abstract_result_inst_constraint_first_eq = EqOp(
        abstract_result_inst_constraint_first.res, constant_bv_1.res
    )

    abstract_result_inst_constraint_c = CallOp.get(
        get_inst_constraint.results[0],
        [c_constant.results[0], abstract_result_inst.results[0]],
    )
    abstract_result_inst_constraint_c_first = FirstOp(
        abstract_result_inst_constraint_c.res
    )
    abstract_result_inst_constraint_c_first_eq = EqOp(
        abstract_result_inst_constraint_c_first.res, constant_bv_0.res
    )
    and_op = AndOp(
        abstract_result_inst_constraint_first_eq.res,
        abstract_result_inst_constraint_c_first_eq.res,
    )
    assert_ops.append(AssertOp(and_op.res))

    return (
        [
            constant_bv_1,
            constant_bv_0,
        ]
        + arg_constant
        + arg_constraints
        + arg_constraints_first
        + [
            c_constant,
            c_constraints,
            c_constraints_first,
            abstract_result,
        ]
        + [
            cfiled_constraint,
            cinst_constraint,
        ]
        + [
            abstract_result_inst,
            abstract_result_inst_constraint,
            abstract_result_inst_constraint_first,
            abstract_result_inst_constraint_first_eq,
            abstract_result_inst_constraint_c,
            abstract_result_inst_constraint_c_first,
            abstract_result_inst_constraint_c_first_eq,
            and_op,
        ]
        + abs_eq_ops
        + assert_ops
        + [CheckSatOp()]
    )


def find_concrete_function(func_name: str, width: int):
    # iterate all semantics and find corresponding comb operation
    result = None
    # print(func_name)
    for k in comb_semantics.keys():
        if k.name == func_name:
            # generate a function with the only comb operation
            # for now, we only handle binary operations and mux
            intTy = IntegerType(width)

            if func_name == "comb.mux":
                funcTy = FunctionType.from_lists([i1, intTy, intTy], [intTy])
                result = FuncOp("comb_mux", funcTy)
                combOp = k(*result.args)
                returnOp = Return(combOp.results[0])
                result.body.block.add_ops([combOp, returnOp])
            else:
                funcTy = FunctionType.from_lists([intTy, intTy], [intTy])
                result = FuncOp(func_name.replace(".", "_"), funcTy)
                if issubclass(k, comb.VariadicCombOperation):
                    combOp = k.create(operands=result.args, result_types=[intTy])
                else:
                    combOp = k(*result.args)
                returnOp = Return(combOp.results[0])
                result.body.block.add_ops([combOp, returnOp])
    assert result is not None and ("Cannot find the concrete function for" + func_name)
    return result


def main() -> None:
    ctx = MLContext()
    arg_parser = argparse.ArgumentParser()
    register_all_arguments(arg_parser)
    args = arg_parser.parse_args()

    # Register all dialects
    ctx.load_dialect(Arith)
    ctx.load_dialect(Builtin)
    ctx.load_dialect(Func)
    ctx.load_dialect(SMTDialect)
    ctx.load_dialect(SMTBitVectorDialect)
    ctx.load_dialect(SMTUtilsDialect)
    ctx.load_dialect(Transfer)
    ctx.load_dialect(Index)

    # Parse the files
    module = parse_file(ctx, args.transfer_functions)
    assert isinstance(module, ModuleOp)

    get_constraint = None
    get_instance_constraint = None

    func_name_to_func = {}
    for func in module.ops:
        if isinstance(func, FuncOp):
            func_name_to_func[func.sym_name.data] = func

    FunctionCallInline(False, func_name_to_func).apply(ctx, module)
    # UnrollTransferLoop().apply(ctx,module)

    for width in solveVectorWidth():
        print("Current width: ", width)
        smt_module = module.clone()
        # expand for loops
        unrollTransferLoop = UnrollTransferLoop(width)
        unrollTransferLoop.apply(ctx, smt_module)

        # add concrete functions
        concrete_funcs = []
        func_name_to_concrete_func_name = {}
        func_name_to_op_constraint = {}
        for op in smt_module.ops:
            if isinstance(op, FuncOp) and "applied_to" in op.attributes:
                concrete_funcname = op.attributes["applied_to"].data[0].data
                concrete_func = find_concrete_function(concrete_funcname, width)
                concrete_funcs.append(concrete_func)
                func_name_to_concrete_func_name[
                    op.sym_name.data
                ] = concrete_func.sym_name.data

            if isinstance(op, FuncOp) and "op_constraint" in op.attributes:
                func_name_to_op_constraint[op.sym_name.data] = op.attributes[
                    "op_constraint"
                ].data

        smt_module.body.block.add_ops(concrete_funcs)

        # lower to SMT
        LowerToSMT.rewrite_patterns = [
            *func_to_smt_patterns,
        ]
        LowerToSMT.type_lowerers = [
            integer_poison_type_lowerer,
            abstract_value_type_lowerer,
            lambda type: transfer_integer_type_lowerer(type, width),
        ]
        LowerToSMT.operation_semantics = {
            **arith_semantics,
            **transfer_semantics,
            **comb_semantics,
        }
        LowerToSMT().apply(ctx, smt_module)
        func_name_to_smt_func: dict[str, DefineFunOp] = {}
        for func in smt_module.ops:
            if isinstance(func, DefineFunOp):
                func_name_to_smt_func[func.fun_name.data] = func
                if func.fun_name.data == "getConstraint":
                    get_constraint = func
                elif func.fun_name.data == "getInstanceConstraint":
                    get_instance_constraint = func
        # return
        for func_pair in module.attributes[KEY_NEED_VERIFY]:
            concrete_funcname, transfer_funcname = func_pair
            print(transfer_funcname)
            transfer_func = func_name_to_smt_func[transfer_funcname.data]
            concrete_func = func_name_to_smt_func[
                func_name_to_concrete_func_name[transfer_funcname.data]
            ]
            op_constraint = None
            if transfer_funcname.data in func_name_to_op_constraint:
                op_constraint = func_name_to_smt_func[
                    func_name_to_op_constraint[transfer_funcname.data]
                ]

            """
            query_module = ModuleOp([], {})
            added_ops = test_abs_inline_check(transfer_func)
            query_module.body.block.add_ops(added_ops)
            FunctionCallInline(True, {}).apply(ctx, query_module)
            LowerToSMT().apply(ctx, query_module)
            print(query_module)
            print_to_smtlib(query_module, sys.stdout)
            """

            if False:
                # basic constraint check
                query_module = ModuleOp([], {})
                added_ops = basic_constraint_check(transfer_func, get_constraint)
                query_module.body.block.add_ops(added_ops)
                FunctionCallInline(True, {}).apply(ctx, query_module)
                LowerToSMT().apply(ctx, query_module)
                print(query_module)
                print(
                    "Basic Constraint Check result:", verify_pattern(ctx, query_module)
                )

            # soundness check
            if True:
                query_module = ModuleOp([], {})
                added_ops = soundness_check(
                    transfer_func,
                    concrete_func,
                    get_constraint,
                    get_instance_constraint,
                    op_constraint,
                )
                query_module.body.block.add_ops(added_ops)
                FunctionCallInline(True, {}).apply(ctx, query_module)
                LowerToSMT().apply(ctx, query_module)
                # print_to_smtlib(query_module, sys.stdout)

                print("Soundness Check result:", verify_pattern(ctx, query_module))

            if False:
                query_module = ModuleOp([], {})
                added_ops = precision_check(
                    transfer_func,
                    concrete_func,
                    get_constraint,
                    get_instance_constraint,
                    op_constraint,
                )
                query_module.body.block.add_ops(added_ops)
                FunctionCallInline(True, {}).apply(ctx, query_module)
                LowerToSMT().apply(ctx, query_module)
                # print_to_smtlib(query_module, sys.stdout)

                print("Precision Check result:", verify_pattern(ctx, query_module))

        print("")


if __name__ == "__main__":
    main()
