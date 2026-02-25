"builtin.module"() ({
  "func.func"() <{sym_name = "concrete_op", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "transfer.sub"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.ashr"(%3, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%4) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "transfer.sub"(%2, %1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.ashr"(%4, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "func.call"(%4, %0) <{callee = @ashr_exact}> : (!transfer.integer, !transfer.integer) -> i1
    %7 = "arith.andi"(%3, %6) : (i1, i1) -> i1
    "func.return"(%7) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
  "func.func"() <{sym_name = "ashr_exact", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_ge = "transfer.cmp"(%arg1, %const0) {predicate = 9 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate = 7 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge, %arg1_le_bitwidth) : (i1, i1) -> i1
    %tmp1 = "transfer.ashr"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %tmp2 = "transfer.shl"(%tmp1, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq = "transfer.cmp"(%tmp2, %arg0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %ret = "arith.andi"(%check, %eq) : (i1, i1) -> i1
    "func.return"(%ret) : (i1) -> ()
  }) : () -> ()
}) : () -> ()