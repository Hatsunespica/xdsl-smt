"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "transfer.mul"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.add"(%3, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.sub"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.and"(%7, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.add"(%0, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.mul"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "func.call"(%4, %5) <{callee = @mul_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.add"(%3, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "func.call"(%3, %7) <{callee = @add_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.sub"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.and"(%9, %11) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.add"(%0, %12) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "func.call"(%0, %12) <{callee = @add_nuw}> : (!transfer.integer, !transfer.integer) -> i1
    %15 = "arith.andi"(%6, %8) : (i1, i1) -> i1
    %16 = "arith.andi"(%15, %10) : (i1, i1) -> i1
    %17 = "arith.andi"(%16, %14) : (i1, i1) -> i1
    "func.return"(%17) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
  "func.func"() <{sym_name = "mul_nuw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %umul_ov = "transfer.umul_overflow"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> i1
    %const1 = "arith.constant"() <{value = true}> : () -> i1
    %check = "arith.xori"(%umul_ov, %const1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "add_nuw", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_ge_arg0 = "transfer.cmp"(%sum, %arg0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %sum_ge_arg1 = "transfer.cmp"(%sum, %arg1) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%sum_ge_arg0, %sum_ge_arg1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
}) : () -> ()