"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer):
    %2 = "transfer.lshr"(%1, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %3 = "transfer.add"(%0, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%3) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer):
    %2 = "arith.constant"() <{value = true}> : () -> i1
    %3 = "transfer.lshr"(%1, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.add"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "func.call"(%0, %3) <{callee = @add_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %6 = "arith.andi"(%2, %5) : (i1, i1) -> i1
    "func.return"(%6) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
  "func.func"() <{sym_name = "add_nuw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_ge_arg0 = "transfer.cmp"(%sum, %arg0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %sum_ge_arg1 = "transfer.cmp"(%sum, %arg1) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%sum_ge_arg0, %sum_ge_arg1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
}) : () -> ()