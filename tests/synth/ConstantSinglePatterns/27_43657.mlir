"builtin.module"() ({
  "func.func"() <{sym_name = "rhs_neq_zero", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %arg1_eq = "transfer.cmp"(%const0, %arg1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const1 = "arith.constant"() <{value = true}> : () -> i1
    %check = "arith.xori"(%arg1_eq, %const1) : (i1, i1) -> i1
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
  "func.func"() <{sym_name = "abs_op_constraint", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    %2 = "arith.constant"() <{value = true}> : () -> i1
    %3 = "func.call"(%1) <{callee = @constant_constraint}> : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %4 = "arith.andi"(%2, %3) : (i1, i1) -> i1
    "func.return"(%4) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer):
    %2 = "transfer.urem"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%2) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer):
    %2 = "arith.constant"() <{value = true}> : () -> i1
    %3 = "transfer.urem"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "func.call"(%0, %1) <{callee = @rhs_neq_zero}> : (!transfer.integer, !transfer.integer) -> i1
    %5 = "arith.andi"(%2, %4) : (i1, i1) -> i1
    "func.return"(%5) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()