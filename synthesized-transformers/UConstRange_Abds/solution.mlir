builtin.module {
  func.func @partial_solution_0_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "0_928_98"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.smax"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.umax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.smax"(%8, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.ashr"(%10, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.udiv"(%11, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.set_sign_bit"(%10) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_high_bits"(%12, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "0_201_84"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%6, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.select"(%10, %8, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.sub"(%5, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.select"(%10, %2, %5) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.sub"(%11, %8) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.set_high_bits"(%12, %14) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.clear_sign_bit"(%15) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %17 = "transfer.udiv"(%13, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.xor"(%1, %16) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.smin"(%17, %18) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.lshr"(%5, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %21 = "transfer.make"(%20, %19) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %21 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, number = "0_1066_2"} {
    %1 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.sub"(%6, %5) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.smin"(%3, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_high_bits"(%4, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.or"(%8, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.clear_low_bits"(%1, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.set_low_bits"(%9, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.xor"(%10, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.neg"(%12) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %15 = "transfer.neg"(%13) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %16 = "transfer.clear_sign_bit"(%14) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %17 = "transfer.make"(%16, %15) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %17 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_1107_73"} {
    %2 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.ashr"(%2, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%4, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %7 : i1
  }
  func.func @partial_solution_3_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_1485_57"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.shl"(%4, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.sdiv"(%3, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countr_one"(%8) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.umax"(%2, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.smin"(%2, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.smax"(%5, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.smax"(%12, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_low_bits"(%2, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "0_1324_65"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smin"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.and"(%1, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.neg"(%7) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.srem"(%8, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%10, %9) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_975_61"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%1, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.smin"(%5, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countr_zero"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.urem"(%4, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.cmp"(%4, %12) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %14 = "transfer.select"(%8, %10, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.select"(%13, %14, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.neg"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %17 = "transfer.clear_low_bits"(%5, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "3_575_37"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%2) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%1, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.select"(%8, %6, %5) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_low_bits"(%3, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.smin"(%10, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.udiv"(%2, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.set_low_bits"(%11, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%10, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "2_53_43"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.smin"(%1, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.lshr"(%6, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.and"(%6, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.sub"(%2, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.mul"(%10, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_1451_74"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %6 = "transfer.cmp"(%3, %4) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %7 = "transfer.cmp"(%5, %2) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = arith.andi %6, %7 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %9 = arith.xori %6, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %9 : i1
  }
  func.func @partial_solution_8_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, number = "0_19_49"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.udiv"(%3, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.umax"(%6, %7) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.add"(%9, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.or"(%8, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.shl"(%5, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.sub"(%4, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.sdiv"(%12, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_118_71"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.cmp"(%3, %3) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %6 = "transfer.cmp"(%4, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %7 = arith.andi %5, %6 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %8 = arith.andi %5, %7 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %8 : i1
  }
  func.func @partial_solution_9_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_1331_35"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.sdiv"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.smin"(%7, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_low_bits"(%8, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.smax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.urem"(%8, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.and"(%11, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%9, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%13, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "4_567_74"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.set_sign_bit"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%5, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_10_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, number = "1_442_2"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%1, %4) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.neg"(%6) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.countl_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.countr_zero"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%8, %12) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%9, %5, %6) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.smin"(%7, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.set_low_bits"(%15, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.lshr"(%14, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_1331_35"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.sdiv"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.smin"(%7, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_low_bits"(%8, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.smax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.urem"(%8, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.and"(%11, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%9, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%13, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_1474_72"} {
    %2 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.smin"(%3, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%6, %5) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %7 : i1
  }
  func.func @partial_solution_12_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_60_57"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.urem"(%2, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.countl_zero"(%5) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.ashr"(%1, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%7) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.neg"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.shl"(%1, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%10, %9) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_12_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_415_88"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.smin"(%3, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%6, %5) {predicate = 6 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.cmp"(%7, %4) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = arith.ori %8, %9 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %10 : i1
  }
  func.func @partial_solution_13_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, number = "1_5_1"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.smax"(%1, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.set_sign_bit"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smax"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.make"(%6, %5) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %7 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_13_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_1399_84"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.xor"(%5, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%7, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.cmp"(%4, %3) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = arith.andi %8, %9 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %10 : i1
  }
  func.func @partial_solution_14_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, number = "1_5_1"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.smax"(%1, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.set_sign_bit"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smax"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.make"(%6, %5) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %7 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_14_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "4_1328_99"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%5) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%5) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.lshr"(%2, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%8, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.cmp"(%5, %4) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = arith.xori %10, %9 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %12 = "transfer.cmp"(%8, %3) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %13 = arith.andi %12, %11 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %13 : i1
  }
  func.func @partial_solution_15_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true, from_weighted_dsl, number = "1_1331_35"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.sdiv"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.smin"(%7, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_low_bits"(%8, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.smax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.urem"(%8, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.and"(%11, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%9, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%13, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_15_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_81_73"} {
    %2 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.add"(%2, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%3, %5) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_0_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_1_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_2_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_2_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_3_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_4_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_5_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_6_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_7_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_7_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
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
  func.func @partial_solution_9(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
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
  func.func @partial_solution_10(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @partial_solution_10_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
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
  func.func @partial_solution_12(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
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
  func.func @partial_solution_13(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_13_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_13_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_14(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_14_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_14_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_15(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.xxx"], CPPCLASS = ["circt::comb::XXXOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_15_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_15_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
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
