"builtin.module"() ({
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
    %3 = "transfer.or"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.add"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%4) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "transfer.or"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.add"(%2, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%3) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()