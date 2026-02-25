"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer):
    %5 = "transfer.and"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.and"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%0, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%5, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%8) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer):
    %5 = "arith.constant"() <{value = true}> : () -> i1
    %6 = "transfer.and"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.and"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%0, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "func.call"(%0, %7) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.or"(%6, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "func.call"(%6, %8) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %12 = "arith.andi"(%5, %9) : (i1, i1) -> i1
    %13 = "arith.andi"(%12, %11) : (i1, i1) -> i1
    "func.return"(%13) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
  "func.func"() <{sym_name = "or_disjoint", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %and = "transfer.and"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq0 = "transfer.cmp"(%and, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%eq0) : (i1) -> ()
  }) : () -> ()
}) : () -> ()