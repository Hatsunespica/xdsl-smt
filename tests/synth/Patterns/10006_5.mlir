"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer, %6 : !transfer.integer, %7 : !transfer.integer):
    %8 = "transfer.xor"(%5, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.add"(%4, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.add"(%8, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.xor"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.add"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.add"(%11, %12) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.add"(%10, %13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%14) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer, %6 : !transfer.integer, %7 : !transfer.integer):
    %8 = "arith.constant"() <{value = true}> : () -> i1
    %9 = "transfer.xor"(%5, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.add"(%4, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.add"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.xor"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.add"(%0, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.add"(%12, %13) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.add"(%11, %14) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%8) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %6 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %7 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()