"builtin.module"() ({
  "func.func"() <{sym_name = "or_disjoint", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %and0 = "transfer.and"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq0 = "transfer.cmp"(%and0, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%eq0) : (i1) -> ()
  }) : () -> ()
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
  "func.func"() <{sym_name = "abs_op_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %4 = "arith.constant"() <{value = true}> : () -> i1
    %5 = "func.call"(%3) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %6 = "arith.andi"(%4, %5) : (i1, i1) -> i1
    "func.return"(%6) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "transfer.or"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.shl"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.or"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%6) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "arith.constant"() <{value = true}> : () -> i1
    %5 = "transfer.or"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "func.call"(%1, %2) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %7 = "transfer.shl"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "func.call"(%0, %3) <{callee = @shl_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %9 = "func.call"(%0, %3) <{callee = @shl_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "func.call"(%0, %3) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.or"(%5, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "func.call"(%5, %7) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %13 = "arith.andi"(%4, %6) : (i1, i1) -> i1
    %14 = "arith.andi"(%13, %8) : (i1, i1) -> i1
    %15 = "arith.andi"(%14, %9) : (i1, i1) -> i1
    %16 = "arith.andi"(%15, %10) : (i1, i1) -> i1
    %17 = "arith.andi"(%16, %12) : (i1, i1) -> i1
    "func.return"(%17) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()