"builtin.module"() ({
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
    %and0 = "transfer.and"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq0 = "transfer.cmp"(%and0, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%eq0) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "constant_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %arg00 = "transfer.get"(%0) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %arg01 = "transfer.get"(%0) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %const0 = "transfer.constant"(%arg00) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%arg00) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %allones = "transfer.sub"(%const0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %or1 = "transfer.or"(%arg00, %arg01) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %cmp1 = "transfer.cmp"(%or1, %allones) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%cmp1) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "abs_op_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "func.call"(%4) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %8 = "func.call"(%5) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "arith.andi"(%6, %7) : (i1, i1) -> i1
    %10 = "arith.andi"(%9, %8) : (i1, i1) -> i1
    "func.return"(%10) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "transfer.shl"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.shl"(%2, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%1, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.or"(%6, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.or"(%0, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.shl"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "func.call"(%3, %4) <{callee = @shl_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %9 = "func.call"(%3, %4) <{callee = @shl_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "func.call"(%3, %4) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.shl"(%2, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "func.call"(%2, %5) <{callee = @shl_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %13 = "func.call"(%2, %5) <{callee = @shl_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %14 = "func.call"(%2, %5) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %15 = "transfer.or"(%1, %11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "func.call"(%1, %11) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %17 = "transfer.or"(%7, %15) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "func.call"(%7, %15) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %19 = "transfer.or"(%0, %17) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "func.call"(%0, %17) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %21 = "arith.andi"(%6, %8) : (i1, i1) -> i1
    %22 = "arith.andi"(%21, %9) : (i1, i1) -> i1
    %23 = "arith.andi"(%22, %10) : (i1, i1) -> i1
    %24 = "arith.andi"(%23, %12) : (i1, i1) -> i1
    %25 = "arith.andi"(%24, %13) : (i1, i1) -> i1
    %26 = "arith.andi"(%25, %14) : (i1, i1) -> i1
    %27 = "arith.andi"(%26, %16) : (i1, i1) -> i1
    %28 = "arith.andi"(%27, %18) : (i1, i1) -> i1
    %29 = "arith.andi"(%28, %20) : (i1, i1) -> i1
    "func.return"(%29) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()