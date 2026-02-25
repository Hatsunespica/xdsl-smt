"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "transfer.and"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%3, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.and"(%2, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.and"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.or"(%8, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.and"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%3, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "func.call"(%3, %7) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.and"(%2, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.and"(%0, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.or"(%10, %11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "func.call"(%10, %11) <{callee = @or_disjoint}> : (!transfer.integer, !transfer.integer) -> i1
    %14 = "arith.andi"(%6, %9) : (i1, i1) -> i1
    %15 = "arith.andi"(%14, %13) : (i1, i1) -> i1
    "func.return"(%15) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
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