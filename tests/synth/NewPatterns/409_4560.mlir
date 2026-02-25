"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "transfer.mul"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.lshr"(%3, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.mul"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.xor"(%4, %5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%6) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "transfer.mul"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.lshr"(%4, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.mul"(%1, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.xor"(%5, %6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%3) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()