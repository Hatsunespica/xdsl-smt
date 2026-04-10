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
  "func.func"() <{sym_name = "abs_op_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %4 = "arith.constant"() <{value = true}> : () -> i1
    %5 = "func.call"(%3) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %6 = "arith.andi"(%4, %5) : (i1, i1) -> i1
    "func.return"(%6) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "transfer.shl"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.or"(%1, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.xor"(%0, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%6) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "arith.constant"() <{value = true}> : () -> i1
    %5 = "transfer.shl"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "func.call"(%2, %3) <{callee = @shifting_amount_less_bitwidth}> : (!transfer.integer, !transfer.integer) -> i1
    %7 = "transfer.or"(%1, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.xor"(%0, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "arith.andi"(%4, %6) : (i1, i1) -> i1
    "func.return"(%9) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()