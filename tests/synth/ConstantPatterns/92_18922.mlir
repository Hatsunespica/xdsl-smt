"builtin.module"() ({
  "func.func"() <{sym_name = "add_nuw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_ge_arg0 = "transfer.cmp"(%sum, %arg0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %sum_ge_arg1 = "transfer.cmp"(%sum, %arg1) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%sum_ge_arg0, %sum_ge_arg1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "add_nsw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0 = "transfer.xor"(%arg0, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1 = "transfer.xor"(%arg1, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %andres = "transfer.and"(%xor0, %xor1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %zero = "transfer.constant"(%arg0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %and_lt_zero = "transfer.cmp"(%andres, %zero) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%and_lt_zero) : (i1) -> ()
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
  "func.func"() <{sym_name = "abs_op_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "func.call"(%2) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %5 = "arith.andi"(%3, %4) : (i1, i1) -> i1
    "func.return"(%5) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "transfer.and"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.add"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%4) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "transfer.and"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.add"(%0, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "func.call"(%0, %4) <{callee = @add_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %7 = "func.call"(%0, %4) <{callee = @add_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %8 = "arith.andi"(%3, %6) : (i1, i1) -> i1
    %9 = "arith.andi"(%8, %7) : (i1, i1) -> i1
    "func.return"(%9) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()