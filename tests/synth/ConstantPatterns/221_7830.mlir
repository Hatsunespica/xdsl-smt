"builtin.module"() ({
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
    %6 = "transfer.or"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%1, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.lshr"(%0, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.or"(%7, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.lshr"(%9, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.or"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%1, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.lshr"(%0, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "func.call"(%0, %4) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.or"(%8, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.lshr"(%11, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "func.call"(%11, %5) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %14 = "arith.andi"(%6, %10) : (i1, i1) -> i1
    %15 = "arith.andi"(%14, %13) : (i1, i1) -> i1
    "func.return"(%15) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()