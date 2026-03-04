"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "transfer.shl"(%5, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%3, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.shl"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.or"(%7, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.or"(%0, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.shl"(%5, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "func.call"(%5, %4) <{callee = @shl_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %9 = "func.call"(%5, %4) <{callee = @shl_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "func.call"(%5, %4) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.or"(%3, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "func.call"(%3, %7) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %13 = "transfer.shl"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "func.call"(%2, %1) <{callee = @shl_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %15 = "func.call"(%2, %1) <{callee = @shl_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %16 = "func.call"(%2, %1) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %17 = "transfer.or"(%11, %13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "func.call"(%11, %13) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %19 = "transfer.or"(%0, %17) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "func.call"(%0, %17) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %21 = "arith.andi"(%6, %8) : (i1, i1) -> i1
    %22 = "arith.andi"(%21, %9) : (i1, i1) -> i1
    %23 = "arith.andi"(%22, %10) : (i1, i1) -> i1
    %24 = "arith.andi"(%23, %12) : (i1, i1) -> i1
    %25 = "arith.andi"(%24, %14) : (i1, i1) -> i1
    %26 = "arith.andi"(%25, %15) : (i1, i1) -> i1
    %27 = "arith.andi"(%26, %16) : (i1, i1) -> i1
    %28 = "arith.andi"(%27, %18) : (i1, i1) -> i1
    %29 = "arith.andi"(%28, %20) : (i1, i1) -> i1
    "func.return"(%29) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
  "func.func"() <{sym_name = "shl_nuw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_ge = "transfer.cmp"(%arg1, %const0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge, %arg1_le_bitwidth) : (i1, i1) -> i1
    %clz = "transfer.countl_zero"(%arg0) : (!transfer.integer) -> !transfer.integer
    %nuw = "transfer.cmp"(%clz, %arg1) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %res = "arith.andi"(%check, %nuw) : (i1, i1) -> i1
    "func.return"(%res) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "shl_nsw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_ge = "transfer.cmp"(%arg1, %const0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge, %arg1_le_bitwidth) : (i1, i1) -> i1
    %cl0 = "transfer.countl_zero"(%arg0) : (!transfer.integer) -> !transfer.integer
    %cl1 = "transfer.countl_one"(%arg0) : (!transfer.integer) -> !transfer.integer
    %is_non_neg = "transfer.cmp"(%arg0, %const0) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl0 = "transfer.cmp"(%arg1, %cl0) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl1 = "transfer.cmp"(%arg1, %cl1) {predicate = 6 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %nsw = "transfer.select"(%is_non_neg, %shamt_lt_cl0, %shamt_lt_cl1) : (i1, i1, i1) -> i1
    %res = "arith.andi"(%check, %nsw) : (i1, i1) -> i1
    "func.return"(%res) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "shifting_amount_less_bitwidth", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_ge = "transfer.cmp"(%arg1, %const0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge, %arg1_le_bitwidth) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "or_disjoint", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %and = "transfer.and"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq0 = "transfer.cmp"(%and, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%eq0) : (i1) -> ()
  }) : () -> ()
}) : () -> ()