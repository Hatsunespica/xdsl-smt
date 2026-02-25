"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "transfer.xor"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.xor"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.xor"(%6, %7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.xor"(%1, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.xor"(%0, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%10) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer, %3 : !transfer.integer, %4 : !transfer.integer, %5 : !transfer.integer):
    %6 = "arith.constant"() <{value = true}> : () -> i1
    %7 = "transfer.xor"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.xor"(%2, %3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.xor"(%7, %8) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.xor"(%1, %9) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.xor"(%0, %10) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%6) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %3 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %4 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %5 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()