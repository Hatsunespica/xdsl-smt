"builtin.module"() ({
  "func.func"() <{sym_name = "rhs_neq_zero", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %arg1_eq = "transfer.cmp"(%const0, %arg1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const1 = "arith.constant"() <{value = true}> : () -> i1
    %check = "arith.xori"(%arg1_eq, %const1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "sub_nsw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %res = "transfer.sub"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor0 = "transfer.xor"(%arg0, %res) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1 = "transfer.xor"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %andres = "transfer.and"(%xor0, %xor1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %zero = "transfer.constant"(%arg0) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %nsw = "transfer.cmp"(%andres, %zero) {predicate = 5 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%nsw) : (i1) -> ()
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
    %5 = "func.call"(%2) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %6 = "func.call"(%3) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %7 = "arith.andi"(%4, %5) : (i1, i1) -> i1
    %8 = "arith.andi"(%7, %6) : (i1, i1) -> i1
    "func.return"(%8) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "transfer.add"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.srem"(%4, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.sub"(%0, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.sub"(%6, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%7) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer):
    %4 = "arith.constant"() <{value = true}> : () -> i1
    %5 = "transfer.add"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.srem"(%5, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "func.call"(%5, %3) <{callee = @rhs_neq_zero}> : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.sub"(%0, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "func.call"(%0, %6) <{callee = @sub_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.sub"(%8, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "func.call"(%8, %1) <{callee = @sub_nsw}> : (!transfer.integer, !transfer.integer) -> i1
    %12 = "arith.andi"(%4, %7) : (i1, i1) -> i1
    %13 = "arith.andi"(%12, %9) : (i1, i1) -> i1
    %14 = "arith.andi"(%13, %11) : (i1, i1) -> i1
    "func.return"(%14) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()