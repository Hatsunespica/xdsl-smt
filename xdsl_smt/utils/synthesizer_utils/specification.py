from __future__ import annotations
from dataclasses import dataclass, field
from io import StringIO
from typing import List, Optional, cast, Any
from xdsl.ir import Operation
from xdsl.dialects.func import FuncOp
from xdsl.dialects.builtin import ModuleOp, i1, FunctionType, IntegerAttr
from xdsl.context import Context

from xdsl_smt.dialects.transfer import AbstractValueType, TransIntegerType
from xdsl_smt.passes.transfer_dead_code_elimination import TransferDeadCodeElimination
from xdsl_smt.passes.transfer_lower import LowerToCpp


def is_transfer_function(func: FuncOp) -> bool:
    return "is_forward" in func.attributes

@dataclass()
class Specification:
    """
    The definition of specification.
    """
    # -------- Static names --------

    CONCRETE_FUNCTION_NAME = "concrete_op"
    MEET_NAME = "meet"
    JOIN_NAME = "join"
    GET_TOP_NAME = "getTop"
    GET_BOTTOM_NAME = "getBottom"
    FROM_CONCRETE_NAME = "fromConcrete"
    CONTAINS_FUNCTION_NAME = "contains"
    DISTANCE_NAME = "distance"
    ABSTRACT_DOMAIN_CONSTRAINT_NAME = "getConstraint"
    INSTANCE_CONSTRAINT_NAME = "getInstanceConstraint"
    CONCRETE_OP_CONSTRAINT = "op_constraint"
    ABSTRACT_OP_CONSTRAINT = "abs_op_constraint"

    # Single FuncOp members
    concrete_function: Optional[FuncOp] = None
    transfer_function: Optional[FuncOp] = None
    meet: Optional[FuncOp] = None
    join: Optional[FuncOp] = None
    get_top: Optional[FuncOp] = None
    get_bottom: Optional[FuncOp] = None
    from_concrete: Optional[FuncOp] = None
    contains_function: Optional[FuncOp] = None
    distance: Optional[FuncOp] = None
    abstract_domain_constraint: Optional[FuncOp] = None
    instance_constraint: Optional[FuncOp] = None
    concrete_op_constraint: Optional[FuncOp] = None
    abstract_op_constraint: Optional[FuncOp] = None
    domain_name: str = ""
    abstract_domain_length: int = 0
    transfer_function_arity:int = 0
    cpp_code: str = ""

    # -------- Custom constructor --------
    def set_fields(self, module:ModuleOp):
        func_name_mapping: dict[str, FuncOp] = {}
        transfer_function_name = ""
        for op in module.ops:
            if isinstance(op, FuncOp):
                func_name = op.sym_name.data
                assert func_name not in func_name_mapping
                func_name_mapping[func_name] = op
                if is_transfer_function(op):
                    transfer_function_name = func_name

        if self.CONCRETE_FUNCTION_NAME in func_name_mapping:
            self.concrete_function = func_name_mapping[self.CONCRETE_FUNCTION_NAME]

        if transfer_function_name != "":
            self.transfer_function = func_name_mapping[transfer_function_name]
            function_type = self.transfer_function.function_type
            self.transfer_function_arity = len(function_type.inputs)

        if self.MEET_NAME in func_name_mapping:
            self.meet = func_name_mapping[self.MEET_NAME]

        if self.JOIN_NAME in func_name_mapping:
            self.join = func_name_mapping[self.JOIN_NAME]

        if self.GET_TOP_NAME in func_name_mapping:
            self.get_top = func_name_mapping[self.GET_TOP_NAME]

        if self.GET_BOTTOM_NAME in func_name_mapping:
            self.get_bottom = func_name_mapping[self.GET_BOTTOM_NAME]

        if self.FROM_CONCRETE_NAME in func_name_mapping:
            self.from_concrete = func_name_mapping[self.FROM_CONCRETE_NAME]

        if self.CONTAINS_FUNCTION_NAME in func_name_mapping:
            self.contains_function = func_name_mapping[self.CONTAINS_FUNCTION_NAME]

        if self.DISTANCE_NAME in func_name_mapping:
            self.distance = func_name_mapping[self.DISTANCE_NAME]

        if self.ABSTRACT_DOMAIN_CONSTRAINT_NAME in func_name_mapping:
            self.abstract_domain_constraint = func_name_mapping[self.ABSTRACT_DOMAIN_CONSTRAINT_NAME]

        if self.INSTANCE_CONSTRAINT_NAME in func_name_mapping:
            self.instance_constraint = func_name_mapping[self.INSTANCE_CONSTRAINT_NAME]

        if self.CONCRETE_OP_CONSTRAINT in func_name_mapping:
            self.concrete_op_constraint = func_name_mapping[self.CONCRETE_OP_CONSTRAINT]

        if self.ABSTRACT_OP_CONSTRAINT in func_name_mapping:
            self.abstract_op_constraint = func_name_mapping[self.ABSTRACT_OP_CONSTRAINT]

    def __init__(self, domain:str, module: ModuleOp):
        self.set_fields(module)
        self.domain_name = domain
        assert self.get_top is not None
        func_type = self.get_top.function_type
        returned_type = list(func_type.outputs)[0]
        assert isinstance(returned_type, AbstractValueType)
        self.abstract_domain_length = returned_type.get_num_fields()




    def verify(self):
        def expect(value:Any, to_be:Any, name:str):
            if value != to_be:
                raise ValueError(f"Expect {name} to be {to_be}")

        def expect_not(value:Any, to_be:Any, name:str):
            if value == to_be:
                raise ValueError(f"Expect {name} not to be {to_be}")

        expect_not(self.domain_name, "", "domain_name")
        expect_not(self.abstract_domain_length, 0, "abstract_domain_length")
        expect_not(self.transfer_function_arity, 0, "transfer_function_arity")


        #Verify function arity for each function
        concrete_type = TransIntegerType()
        abstract_type = AbstractValueType([concrete_type]*self.abstract_domain_length)

        expect_not(self.abstract_domain_constraint, None, "abstract_domain_constraint" )
        expect(self.abstract_domain_constraint.function_type,
               FunctionType.from_lists([abstract_type],[i1]),
               "function type of abstract_domain_constraint")

        # ---- concrete_function ----
        expect_not(self.concrete_function, None, "concrete_function")
        expect(
            self.concrete_function.function_type,
            FunctionType.from_lists([concrete_type]*self.transfer_function_arity, [concrete_type]),
            "function type of concrete_function",
        )

        # ---- meet ----
        expect_not(self.meet, None, "meet")
        expect(
            self.meet.function_type,
            FunctionType.from_lists([abstract_type, abstract_type], [abstract_type]),
            "function type of meet",
        )

        # ---- join ----
        expect_not(self.join, None, "join")
        expect(
            self.join.function_type,
            FunctionType.from_lists([abstract_type, abstract_type], [abstract_type]),
            "function type of join",
        )

        # ---- get_top ----
        expect_not(self.get_top, None, "get_top")
        expect(
            self.get_top.function_type,
            FunctionType.from_lists([abstract_type], [abstract_type]),
            "function type of get_top",
        )

        # ---- get_bottom ----
        expect_not(self.get_bottom, None, "get_bottom")
        expect(
            self.get_bottom.function_type,
            FunctionType.from_lists([abstract_type], [abstract_type]),
            "function type of get_bottom",
        )

        # ---- from_concrete ----
        expect_not(self.from_concrete, None, "from_concrete")
        expect(
            self.from_concrete.function_type,
            FunctionType.from_lists([concrete_type], [abstract_type]),
            "function type of from_concrete",
        )

        # ---- contains_function ----
        expect_not(self.contains_function, None, "contains_function")
        expect(
            self.contains_function.function_type,
            FunctionType.from_lists([abstract_type, abstract_type], [i1]),
            "function type of contains_function",
        )

        # ---- distance ----
        expect_not(self.distance, None, "distance")
        expect(
            self.distance.function_type,
            FunctionType.from_lists([abstract_type, abstract_type], [concrete_type]),
            "function type of distance",
        )


        # ---- instance_constraint ----
        expect_not(self.instance_constraint, None, "instance_constraint")
        expect(
            self.instance_constraint.function_type,
            FunctionType.from_lists([abstract_type, concrete_type], [i1]),
            "function type of instance_constraint",
        )

        # ---- concrete_op_constraint ----
        if self.concrete_op_constraint is not None:
            expect(
                self.concrete_op_constraint.function_type,
                FunctionType.from_lists(list(self.concrete_function.function_type.inputs), [i1]),
                "function type of concrete_op_constraint",
            )

        # ---- abstract_op_constraint ----
        if self.abstract_op_constraint is not None:
            expect(
                self.abstract_op_constraint.function_type,
                FunctionType.from_lists(list(self.transfer_function.function_type.inputs), [i1]),
                "function type of abstract_op_constraint",
            )

    def as_func_list(self) -> list[FuncOp]:
        funcs = [
            self.meet,
            self.join,
            self.get_top,
            self.get_bottom,
            self.from_concrete,
            self.contains_function,
            self.distance,
            self.abstract_domain_constraint,
            self.instance_constraint,
            self.concrete_op_constraint,
            self.abstract_op_constraint,
        ]
        return [func for func in funcs if func is not None]

    def lower_to_cpp(self, context:Context) -> str:
        # Cached cpp code
        if self.cpp_code != "":
            return self.cpp_code

        def print_to_cpp(func:FuncOp) -> str:
            sio = StringIO()
            cloned_func = func.clone()
            TransferDeadCodeElimination().apply(context, cast(ModuleOp, cloned_func))
            LowerToCpp(sio).apply(context, cast(ModuleOp, cloned_func))
            return sio.getvalue()

        self.verify()
        funcs = [
            self.meet,
            self.join,
            self.get_top,
            self.get_bottom,
            self.from_concrete,
            self.contains_function,
            self.distance,
            self.abstract_domain_constraint,
            self.instance_constraint,
            self.concrete_op_constraint,
            self.abstract_op_constraint,
        ]

        should_combine_funcs:list[FuncOp] = [
            self.concrete_function,
        ]

        CPP_HEAD="""
        #include "llvm/ADT/APInt.h"

        using namespace llvm;
        using namespace std;

        extern "C" void evalHead(){};\n\n
"""

        self.cpp_code = CPP_HEAD + "\n\n".join([print_to_cpp(func) for func in funcs if func is not None])
        for func in should_combine_funcs:
            func.attributes["should_combine"] = IntegerAttr.from_bool(True)
        self.cpp_code += "\n\n".join([print_to_cpp(func) for func in should_combine_funcs])

        return self.cpp_code





