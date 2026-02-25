"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer):
    %5 = "transfer.and"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.or"(%2, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%1, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%0, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%8) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer):
    %5 = "arith.constant"() <{value = true}> : () -> i1
    %6 = "transfer.and"(%3, %4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%2, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "func.call"(%2, %6) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.or"(%1, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "func.call"(%1, %7) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.or"(%0, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "func.call"(%0, %9) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %13 = "arith.andi"(%5, %8) : (i1, i1) -> i1
    %14 = "arith.andi"(%13, %10) : (i1, i1) -> i1
    %15 = "arith.andi"(%14, %12) : (i1, i1) -> i1
    "func.return"(%15) : (i1) -> ()
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