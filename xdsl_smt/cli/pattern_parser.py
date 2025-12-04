import re
from dataclasses import dataclass
from typing import List, Optional
import sys
from xdsl.dialects.func import FuncOp, FunctionType, ReturnOp, CallOp, Func
from xdsl.ir.core import Operation, SSAValue
from xdsl.dialects.builtin import Builtin, i1, ModuleOp, IntegerAttr, ArrayAttr, StringAttr
import xdsl.dialects.arith as arith
from xdsl.printer import Printer
from xdsl_smt.dialects.transfer import TransIntegerType, Transfer, AbstractValueType
import xdsl_smt.dialects.transfer as tf
from xdsl.context import Context
from xdsl.parser import Parser

# -------------------------------
# Data structures
# -------------------------------


@dataclass
class Argument:
    name: str
    typ: str


@dataclass
class Instruction:
    result: Optional[str]
    op: str
    flags: List[str]  # NEW: list of flags like ["nuw", "nsw"]
    typ: Optional[str]
    operands: List[str]


@dataclass
class FunctionDef:
    name: str
    return_type: str
    args: List[Argument]
    instructions: List[Instruction]


# -------------------------------
# Main parser
# -------------------------------


def parse_llvm_function(text: str) -> FunctionDef:
    text = text.strip()

    # Parse header
    header_re = re.compile(r"define\s+(?P<ret>\w+)\s+@(?P<name>\w+)\((?P<args>[^)]*)\)")
    header_m = header_re.search(text)
    if not header_m:
        raise ValueError("Cannot parse function header")

    fn_name = header_m.group("name")
    ret_type = header_m.group("ret")
    args_raw = header_m.group("args").strip()

    # Parse arguments
    args = []
    if args_raw:
        for a in args_raw.split(","):
            a = a.strip()
            m = re.match(r"(?P<typ>\w+)\s+(?P<name>%\"?\w+\"?)", a)
            if not m:
                raise ValueError(f"Bad argument: {a}")
            typ = m.group("typ")
            name = m.group("name")
            args.append(Argument(name=name, typ=typ))

    # -------------------------------
    # Parse instructions inside body
    # -------------------------------
    body = text[text.index("{") + 1 : text.rindex("}")].strip()
    lines = [ln.strip() for ln in body.splitlines() if ln.strip()]

    instructions = []
    for line in lines:
        # ret
        if line.startswith("ret "):
            m = re.match(r"ret\s+(?P<typ>\w+)\s+(?P<op>%\S+)", line)
            instructions.append(
                Instruction(
                    result=None,
                    op="ret",
                    flags=[],
                    typ=m.group("typ"),
                    operands=[m.group("op")],
                )
            )
            continue

        # binary ops with potential flags:
        # %3 = add nsw nuw i32 %1, %2
        m = re.match(
            r"(?P<res>%\S+)\s*=\s*(?P<op>\w+)\s+(?P<flags>(?:nsw|nuw|exact|disjoint|\s)+)?(?P<typ>\w+)\s+(?P<lhs>%\S+),\s*(?P<rhs>%\S+)",
            line,
        )
        if m:
            op = m.group("op")
            flags_str = m.group("flags") or ""
            flags = [
                f for f in flags_str.split() if f in ("nsw", "nuw", "exact", "disjoint")
            ]
            typ = m.group("typ")
            lhs = m.group("lhs")
            rhs = m.group("rhs")

            instructions.append(
                Instruction(
                    result=m.group("res"),
                    op=op,
                    flags=flags,
                    typ=typ,
                    operands=[lhs, rhs],
                )
            )
            continue

        raise ValueError(f"Cannot parse line: {line}")

    return FunctionDef(
        name=fn_name,
        return_type=ret_type,
        args=args,
        instructions=instructions,
    )


def load_file(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        content = content.replace("%int", "i32")
        func = parse_llvm_function(content)
        return func


def parse_mlir_func(context: Context, func: str) -> FuncOp:
    parser = Parser(context, func)
    module = parser.parse_op()
    assert isinstance(module, FuncOp)
    return module


value_mapping: dict[str, SSAValue] = {}
op_mapping: dict[str, type[tf.BinOp]] = {
    "and": tf.AndOp,
    "or": tf.OrOp,
    "xor": tf.XorOp,
    "add": tf.AddOp,
    "sub": tf.SubOp,
    "ashr": tf.AShrOp,
    "lshr": tf.LShrOp,
    "shl": tf.ShlOp,
    "mul": tf.MulOp,
    "sdiv": tf.SDivOp,
    "udiv": tf.UDivOp,
    "srem": tf.SRemOp,
    "urem": tf.URemOp,
}

constraint_mapping: dict[str, dict[str, FuncOp]] = {}


def init_constraint_mapping(context: Context):
    global constraint_mapping
    constraint_mapping = {
        "or": {
            "disjoint": parse_mlir_func(
                context,
                """"func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %and = "transfer.and"(%arg0,%arg1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %eq0 = "transfer.cmp"(%and, %const0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%eq0) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "or_disjoint"} : () -> ()""",
            )
        },
        "shl": {
            "nsw": parse_mlir_func(
                context,
                """"func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

    %cl0 = "transfer.countl_zero"(%arg0) : (!transfer.integer) -> !transfer.integer
    %cl1 = "transfer.countl_one"(%arg0) : (!transfer.integer) -> !transfer.integer
    %is_non_neg = "transfer.cmp"(%arg0, %const0) {predicate=5:i64}: (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl0 = "transfer.cmp"(%arg1, %cl0) {predicate=6:i64}: (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl1 = "transfer.cmp"(%arg1, %cl1) {predicate=6:i64}: (!transfer.integer, !transfer.integer) -> i1
    %nsw = "transfer.select"(%is_non_neg, %shamt_lt_cl0, %shamt_lt_cl1): (i1, i1, i1) -> i1

    %res = "arith.andi"(%check, %nsw) : (i1, i1) -> i1
    "func.return"(%res) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "shl_nsw"} : () -> ()""",
            ),
            "nuw": parse_mlir_func(
                context,
                """
                                  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

    %clz = "transfer.countl_zero"(%arg0) : (!transfer.integer) -> !transfer.integer
    %nuw = "transfer.cmp"(%clz, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1

    %res = "arith.andi"(%check, %nuw) : (i1, i1) -> i1
    "func.return"(%res) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "shl_nuw"} : () -> ()
                                  """,
            ),
        },
        "sub": {
            "nsw": parse_mlir_func(
                context,
                """
            "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %res = "transfer.sub"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %xor0 = "transfer.xor"(%arg0, %res) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %xor1 = "transfer.xor"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %andres = "transfer.and"(%xor0, %xor1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %zero = "transfer.constant"(%arg0){value=0:index} : (!transfer.integer) -> !transfer.integer
        %nsw = "transfer.cmp"(%andres, %zero) {predicate=5:i64}: (!transfer.integer, !transfer.integer) -> i1
        "func.return"(%nsw) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "sub_nsw"} : () -> ()
            """,
            ),
            "nuw": parse_mlir_func(
                context,
                """
        "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %check = "transfer.cmp"(%arg0, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "sub_nuw"} : () -> ()
        """,
            ),
        },
        "add": {
            "nuw": parse_mlir_func(
                context,
                """
        "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %sum_ge_arg0 = "transfer.cmp"(%sum, %arg0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
        %sum_ge_arg1 = "transfer.cmp"(%sum, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
        %check = "arith.andi"(%sum_ge_arg0, %sum_ge_arg1) : (i1, i1) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "add_nuw"} : () -> ()""",
            ),
            "nsw": parse_mlir_func(
                context,
                """
        "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %xor0 = "transfer.xor"(%arg0, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %xor1 = "transfer.xor"(%arg1, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %andres = "transfer.and"(%xor0, %xor1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %zero = "transfer.constant"(%arg0){value=0:index} : (!transfer.integer) -> !transfer.integer
        %and_lt_zero = "transfer.cmp"(%andres, %zero) {predicate=5:i64}: (!transfer.integer, !transfer.integer) -> i1
        "func.return"(%and_lt_zero) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "add_nsw"} : () -> ()""",
            ),
        },
        "mul": {
            "nsw": parse_mlir_func(
                context,
                """
    "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %smul_ov = "transfer.smul_overflow"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> i1
        %const1 = "arith.constant"() {value=1:i1}: () -> i1
        %check = "arith.xori"(%smul_ov, %const1) : (i1, i1) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "mul_nsw"} : () -> ()
            """,
            ),
            "nuw": parse_mlir_func(
                context,
                """
            "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %umul_ov = "transfer.umul_overflow"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> i1
        %const1 = "arith.constant"() {value=1:i1}: () -> i1
        %check = "arith.xori"(%umul_ov, %const1) : (i1, i1) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "mul_nuw"} : () -> ()
            """,
            ),
        },
        "lshr": {
            "exact": parse_mlir_func(
                context,
                """
      "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
        %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
        %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
        %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
        %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

        %tmp1 = "transfer.lshr"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %tmp2 = "transfer.shl"(%tmp1, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %eq = "transfer.cmp"(%tmp2, %arg0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

        %ret = "arith.andi"(%check, %eq) : (i1, i1) -> i1
        "func.return"(%ret) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "lshr_exact"} : () -> ()
        """,
            )
        },
        "ashr": {
            "exact": parse_mlir_func(
                context,
                """
          "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
        %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
        %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
        %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
        %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

        %tmp1 = "transfer.ashr"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %tmp2 = "transfer.shl"(%tmp1, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %eq = "transfer.cmp"(%tmp2, %arg0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

        %ret = "arith.andi"(%check, %eq) : (i1, i1) -> i1
        "func.return"(%ret) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "ashr_exact"} : () -> ()
        """,
            )
        },
        "sdiv": {
            "exact": parse_mlir_func(
                context,
                """
    "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
        %arg1_neq_0 = "transfer.cmp"(%const0, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
        %arg0_eq_0 = "transfer.cmp"(%const0, %arg0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1
        %arg0_plus_arg0 = "transfer.add"(%arg0, %arg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %arg0_plus_arg0_neq_0 = "transfer.cmp"(%arg0_plus_arg0, %const0) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
        %arg0_neq_smin = "arith.ori"(%arg0_eq_0, %arg0_plus_arg0_neq_0) : (i1, i1) -> i1
        %minus1 = "transfer.get_all_ones"(%arg0) : (!transfer.integer) -> !transfer.integer
        %arg1_neq_minus1 = "transfer.cmp"(%minus1, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
        %not_ub2 = "arith.ori"(%arg0_neq_smin, %arg1_neq_minus1) : (i1, i1) -> i1
        %not_ub = "arith.andi"(%arg1_neq_0, %not_ub2) : (i1, i1) -> i1

        %const1 = "transfer.constant"(%arg1) {value=1:index}:(!transfer.integer)->!transfer.integer
        %safe_arg1 = "transfer.select"(%arg1_neq_0, %arg1, %const1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
        %rem = "transfer.srem"(%arg0, %safe_arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %exact = "transfer.cmp"(%rem, %const0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

        %check = "arith.andi"(%exact, %not_ub) : (i1, i1) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "sidv_exact"} : () -> ()
            """,
            )
        },
        "udiv": {
            "exact": parse_mlir_func(
                context,
                """
    "func.func"() ({
      ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
        %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
        %const1 = "transfer.constant"(%arg1) {value=1:index}:(!transfer.integer)->!transfer.integer
        %arg1_neq_0 = "transfer.cmp"(%const0, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1

        %safe_arg1 = "transfer.select"(%arg1_neq_0, %arg1, %const1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
        %rem = "transfer.urem"(%arg0, %safe_arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
        %exact = "transfer.cmp"(%rem, %const0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

        %check = "arith.andi"(%exact, %arg1_neq_0) : (i1, i1) -> i1
        "func.return"(%check) : (i1) -> ()
      }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "udiv_exact"} : () -> ()
            """,
            )
        },
    }


def get_op(inst: Instruction) -> Operation:
    global value_mapping
    arg_list: list[SSAValue] = []
    for arg in inst.operands:
        assert arg in value_mapping
        arg_list.append(value_mapping[arg])

    if inst.op == "ret":
        assert len(arg_list) == 1
        return ReturnOp(arg_list[0])
    else:
        assert inst.op in op_mapping
        op_type = op_mapping[inst.op]
        assert len(arg_list) == 2
        op = op_type(arg_list[0], arg_list[1])
        value_mapping[inst.result] = op.result
        return op


def to_mlir_func(func_def: FunctionDef, func_name: str) -> FuncOp:
    func_type = FunctionType.from_lists(
        [TransIntegerType() for _ in func_def.args], [TransIntegerType()]
    )

    func = FuncOp(func_name, func_type)
    for arg, arg_val in zip(func_def.args, func.args):
        value_mapping[arg.name] = arg_val
    blk = func.body.block
    for inst in func_def.instructions:
        blk.add_op(get_op(inst))

    return func


def get_constraint_funcs(inst: Instruction) -> list[FuncOp]:
    if inst.flags:
        assert inst.op in constraint_mapping
        return [constraint_mapping[inst.op][flag] for flag in inst.flags]
    return []


def combine_and_ops(ops: list[Operation]) -> tuple[list[Operation], SSAValue]:
    result_ops: list[Operation] = []
    result = ops[0].results[0]
    for i in range(1, len(ops)):
        result_ops.append(arith.AndIOp(result, ops[i].results[0]))
        result = result_ops[-1].results[0]
    return result_ops, result


def to_mlir_constraint(func_def: FunctionDef) -> tuple[FuncOp, list[FuncOp]]:
    global value_mapping
    value_mapping = {}
    func_type = FunctionType.from_lists([TransIntegerType() for _ in func_def.args], [i1])

    func = FuncOp("op_constraint", func_type)
    for arg, arg_val in zip(func_def.args, func.args):
        value_mapping[arg.name] = arg_val
    blk = func.body.block

    constraint_list: list[Operation] = [arith.ConstantOp.from_int_and_width(1, 1)]
    blk.add_op(constraint_list[-1])
    constraint_func_mapping: dict[str, FuncOp] = {}
    for inst in func_def.instructions:
        cur_op = get_op(inst)
        if isinstance(cur_op, ReturnOp):
            continue
        blk.add_op(cur_op)
        constraint_funcs = get_constraint_funcs(inst)
        for c_func in constraint_funcs:
            if c_func.sym_name.data not in constraint_func_mapping:
                constraint_func_mapping[c_func.sym_name.data] = c_func
            applied_op = CallOp(c_func.sym_name.data, cur_op.operands, [i1])
            blk.add_op(applied_op)
            constraint_list.append(applied_op)
    result_ops, result = combine_and_ops(constraint_list)
    blk.add_ops(result_ops)
    blk.add_op(ReturnOp(result))
    return func, list(constraint_func_mapping.values())


def make_tf_signature(func_def:FunctionDef) -> FuncOp:
    kb_type = AbstractValueType([TransIntegerType(), TransIntegerType()])
    func_type = FunctionType.from_lists([kb_type for _ in func_def.args], [kb_type])
    func_op = FuncOp("patternImpl", func_type)
    blk  = func_op.body.block
    blk.add_op(ReturnOp(blk.args[0]))
    func_op.attributes["is_forward"] = IntegerAttr.from_int_and_width(1,1)
    func_op.attributes["applied_to"] = ArrayAttr([StringAttr("llvm_pattern")])
    return func_op

def to_spec(func_path: str) -> ModuleOp:
    # Register all dialects
    context = Context()
    context.load_dialect(Builtin)
    context.load_dialect(Func)
    context.load_dialect(arith.Arith)
    context.load_dialect(Transfer)
    init_constraint_mapping(context)
    func = load_file(func_path)
    concrete_op = to_mlir_func(func, "concrete_op")
    op_constraint, extra_funcs = to_mlir_constraint(func)
    tf_signature = make_tf_signature(func)
    module_op = ModuleOp([concrete_op, op_constraint, tf_signature] + extra_funcs)
    return module_op


def main():
    f = sys.argv[1]
    printer = Printer(print_generic_format=True)
    printer.print_op(to_spec(f))

