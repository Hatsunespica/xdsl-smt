builtin.module {
  func.func @partial_solution_0_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "0_1311_72"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%4, %6) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.countr_zero"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_low_bits"(%1, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.select"(%8, %4, %5) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.set_low_bits"(%10, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.mul"(%6, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%8, %4, %5) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.umin"(%14, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.xor"(%15, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.cmp"(%10, %13) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %18 = "transfer.countr_zero"(%10) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %19 = "transfer.select"(%17, %16, %2) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.clear_low_bits"(%12, %18) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %21 = "transfer.make"(%20, %19) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %21 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_0_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_848_75"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.mul"(%6, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%7, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.cmp"(%4, %3) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.cmp"(%4, %5) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = arith.andi %9, %10 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %12 = arith.xori %8, %11 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %12 : i1
  }
  func.func @partial_solution_1_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "2_397_40"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%6, %1) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %4, %9) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.set_high_bits"(%10, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.countl_zero"(%10) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.add"(%11, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.set_high_bits"(%4, %12) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.countl_zero"(%13) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %16 = "transfer.urem"(%13, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.set_high_bits"(%14, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "0_1386_61"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.set_high_bits"(%2, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.set_high_bits"(%4, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.countl_zero"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.shl"(%10, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.neg"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.xor"(%13, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.udiv"(%4, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.and"(%14, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.set_high_bits"(%12, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "0_50_52"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.umin"(%5, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.and"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.and"(%8, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.ashr"(%4, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.countl_zero"(%10) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.or"(%8, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umin"(%8, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_sign_bit"(%13) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %15 = "transfer.clear_high_bits"(%12, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "0_177_47"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.umin"(%6, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.and"(%1, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.and"(%2, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%5, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.countl_one"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%9) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.clear_high_bits"(%12, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%10, %6, %11) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.lshr"(%13, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.umin"(%8, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.mul"(%16, %16) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.mul"(%1, %17) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.shl"(%9, %14) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.make"(%19, %18) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "2_70_24"} {
    %1 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.constant"(%1) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %3 = "transfer.constant"(%1) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.constant"(%1) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_bit_width"(%1) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.umax"(%4, %5) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.smax"(%3, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.set_low_bits"(%7, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.srem"(%1, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.set_high_bits"(%9, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.clear_sign_bit"(%10) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.umax"(%1, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.shl"(%8, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.and"(%12, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.srem"(%13, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.neg"(%14) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %17 = "transfer.make"(%16, %15) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %17 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_1221_84"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.neg"(%3) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%5, %3) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.cmp"(%6, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = arith.xori %7, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %9 : i1
  }
  func.func @partial_solution_6_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "0_158_2"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.or"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%4, %5) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %7 = "transfer.set_sign_bit"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.set_high_bits"(%7, %3) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.neg"(%8) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%6, %5, %9) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%10, %9) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "1_241_23"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.countl_one"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.add"(%5, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.set_low_bits"(%4, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.ashr"(%4, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.mul"(%1, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.smin"(%10, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "2_33_37"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.add"(%5, %5) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.set_high_bits"(%4, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.ashr"(%2, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.shl"(%7, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.and"(%1, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.cmp"(%9, %4) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %12 = "transfer.and"(%10, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.select"(%11, %12, %12) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.urem"(%7, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_1005_89"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.set_high_bits"(%2, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%4, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %7 : i1
  }
  func.func @partial_solution_9_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "0_769_94"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.or"(%3, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%2, %4) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.urem"(%2, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countl_one"(%7) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.select"(%8, %9, %5) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.set_high_bits"(%1, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_396_70"} {
    %2 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.ashr"(%4, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.lshr"(%7, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%2, %8) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %9 : i1
  }
  func.func @partial_solution_10_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "3_899_33"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%2, %1) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.select"(%8, %5, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.and"(%4, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.add"(%4, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.countl_zero"(%11) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.clear_low_bits"(%10, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_high_bits"(%3, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.add"(%12, %9) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.clear_low_bits"(%2, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.clear_high_bits"(%1, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.mul"(%14, %17) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.smax"(%16, %13) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.make"(%19, %18) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "2_1253_33"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%4) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%1, %3) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.or"(%6, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.xor"(%10, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.udiv"(%1, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.mul"(%11, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%9, %8, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.smin"(%3, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.srem"(%5, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.set_high_bits"(%13, %14) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_601_87"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%5) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.umin"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.or"(%7, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%6, %8) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %9 : i1
  }
  func.func @partial_solution_12_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, from_weighted_dsl, number = "1_871_57"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.mul"(%3, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.sub"(%7, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.sdiv"(%9, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.ashr"(%1, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%6, %8) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_high_bits"(%12, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.and"(%14, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.shl"(%11, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.make"(%16, %15) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %17 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_12_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_769_84"} {
    %2 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%5, %7) {predicate = 6 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.set_high_bits"(%2, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%4, %9) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = arith.andi %8, %10 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %11 : i1
  }
  func.func @partial_solution_13_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "2_1406_6"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.add"(%4, %4) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.clear_low_bits"(%1, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.sub"(%2, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.urem"(%7, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.umin"(%6, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.or"(%6, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.countl_zero"(%8) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_low_bits"(%9, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.mul"(%12, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.smax"(%12, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.add"(%13, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_14_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "3_953_20"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.smax"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.lshr"(%5, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.countl_zero"(%10) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.set_low_bits"(%3, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.cmp"(%2, %3) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %14 = "transfer.select"(%13, %8, %4) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%9, %11) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.udiv"(%2, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.lshr"(%14, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.clear_high_bits"(%16, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_15_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true, number = "3_324_15"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%1, %1) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.select"(%7, %5, %6) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.shl"(%1, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%2, %1) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.umax"(%5, %5) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.add"(%9, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%10, %11, %6) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.cmp"(%4, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %16 = "transfer.select"(%15, %14, %6) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.shl"(%13, %16) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.urem"(%17, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.srem"(%17, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.make"(%19, %18) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_0_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_0_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_1_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_2_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_3_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_4_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_5_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_5_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_6_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_7_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_8_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_8_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_9_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_9_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_10(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_10_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_11_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_11_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_12(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_12_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_12_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_13(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_13_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_14(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_14_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_15(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.modu"], CPPCLASS = ["circt::comb::AndOp"], is_forward = true} {
    %2 = func.call @partial_solution_15_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @solution(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> {
    %2 = func.call @partial_solution_0(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = func.call @partial_solution_1(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %4 = func.call @partial_solution_2(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %5 = func.call @partial_solution_3(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = func.call @partial_solution_4(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %7 = func.call @partial_solution_5(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %8 = func.call @partial_solution_6(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %9 = func.call @partial_solution_7(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %10 = func.call @partial_solution_8(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %11 = func.call @partial_solution_9(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %12 = func.call @partial_solution_10(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %13 = func.call @partial_solution_11(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %14 = func.call @partial_solution_12(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %15 = func.call @partial_solution_13(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %16 = func.call @partial_solution_14(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %17 = func.call @partial_solution_15(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %18 = func.call @meet(%2, %3) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %19 = func.call @meet(%18, %4) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %20 = func.call @meet(%19, %5) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %21 = func.call @meet(%20, %6) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %22 = func.call @meet(%21, %7) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %23 = func.call @meet(%22, %8) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %24 = func.call @meet(%23, %9) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %25 = func.call @meet(%24, %10) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %26 = func.call @meet(%25, %11) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %27 = func.call @meet(%26, %12) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %28 = func.call @meet(%27, %13) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %29 = func.call @meet(%28, %14) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %30 = func.call @meet(%29, %15) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %31 = func.call @meet(%30, %16) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %32 = func.call @meet(%31, %17) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %32 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
}
