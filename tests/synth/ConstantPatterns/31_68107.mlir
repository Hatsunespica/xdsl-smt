"builtin.module"() ({
  "func.func"() <{sym_name = "sidv_exact", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %arg1_neq = "transfer.cmp"(%const0, %arg1) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg0_eq = "transfer.cmp"(%const0, %arg0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg0_plus_arg0 = "transfer.add"(%arg0, %arg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %arg0_plus_arg0_neq = "transfer.cmp"(%arg0_plus_arg0, %const0) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %arg0_neq_smin = "arith.ori"(%arg0_eq, %arg0_plus_arg0_neq) : (i1, i1) -> i1
    %minus1 = "transfer.get_all_ones"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_neq_minus1 = "transfer.cmp"(%minus1, %arg1) {predicate = 1 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %not_ub2 = "arith.ori"(%arg0_neq_smin, %arg1_neq_minus1) : (i1, i1) -> i1
    %not_ub = "arith.andi"(%arg1_neq, %not_ub2) : (i1, i1) -> i1
    %const1 = "transfer.constant"(%arg1) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %safe_arg1 = "transfer.select"(%arg1_neq, %arg1, %const1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rem = "transfer.srem"(%arg0, %safe_arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %exact = "transfer.cmp"(%rem, %const0) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%exact, %not_ub) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "rhs_neq_zero", function_type = (!transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%arg0 : !transfer.integer, %arg1 : !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value = 0 : index} : (!transfer.integer) -> !transfer.integer
    %arg1_eq = "transfer.cmp"(%const0, %arg1) {predicate = 0 : i64} : (!transfer.integer, !transfer.integer) -> i1
    %const1 = "arith.constant"() <{value = true}> : () -> i1
    %check = "arith.xori"(%arg1_eq, %const1) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) : () -> ()
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
    %3 = "transfer.sub"(%1, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.sdiv"(%3, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%4) : (!transfer.integer) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "op_constraint", function_type = (!transfer.integer, !transfer.integer, !transfer.integer) -> i1}> ({
  ^0(%0 : !transfer.integer, %1 : !transfer.integer, %2 : !transfer.integer):
    %3 = "arith.constant"() <{value = true}> : () -> i1
    %4 = "transfer.sub"(%1, %0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.sdiv"(%4, %2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "func.call"(%4, %2) <{callee = @sidv_exact}> : (!transfer.integer, !transfer.integer) -> i1
    %7 = "func.call"(%4, %2) <{callee = @rhs_neq_zero}> : (!transfer.integer, !transfer.integer) -> i1
    %8 = "arith.andi"(%3, %6) : (i1, i1) -> i1
    %9 = "arith.andi"(%8, %7) : (i1, i1) -> i1
    "func.return"(%9) : (i1) -> ()
  }) : () -> ()
  "func.func"() <{sym_name = "patternImpl", function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>}> ({
  ^0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {is_forward = true, applied_to = ["llvm_pattern"], CPPCLASS = ["non_cpp_class"]} : () -> ()
}) : () -> ()