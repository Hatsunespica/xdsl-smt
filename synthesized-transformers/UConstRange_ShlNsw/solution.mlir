builtin.module {
  func.func @partial_solution_0_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_1385_68"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_zero"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.add"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.lshr"(%8, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.udiv"(%9, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.smax"(%6, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.countl_zero"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.clear_sign_bit"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%2, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.lshr"(%13, %12) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_434_37"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.set_sign_bit"(%1) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_sign_bit"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.countl_zero"(%7) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.set_high_bits"(%3, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%8) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.countl_one"(%7) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.set_high_bits"(%3, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.neg"(%14) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %16 = "transfer.xor"(%11, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.clear_low_bits"(%15, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.umax"(%17, %16) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.urem"(%1, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.make"(%19, %18) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "2_1337_24"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.umax"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.set_high_bits"(%5, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.sdiv"(%3, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countr_one"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.shl"(%7, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.shl"(%2, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.set_high_bits"(%12, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.umin"(%11, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_123_43"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.set_sign_bit"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.umin"(%2, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_low_bits"(%5, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_sign_bit"(%9) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.or"(%10, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.umin"(%7, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "2_704_0"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.clear_low_bits"(%4, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.mul"(%2, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.xor"(%7, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.smin"(%2, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.add"(%8, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%11, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_high_bits"(%8, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "2_504_28"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.add"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.set_low_bits"(%1, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.mul"(%6, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.clear_sign_bit"(%7) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.ashr"(%7, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.neg"(%10) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.neg"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.umin"(%8, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.make"(%13, %12) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %14 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "2_584_21"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.udiv"(%5, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.add"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.set_sign_bit"(%7) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.umax"(%7, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.smin"(%4, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.or"(%9, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.smin"(%4, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.smin"(%12, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.shl"(%13, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "3_67_51"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.umax"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.neg"(%9) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.umax"(%10, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.cmp"(%7, %7) {predicate = 6 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %13 = "transfer.select"(%12, %4, %10) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.clear_sign_bit"(%6) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %15 = "transfer.shl"(%13, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.xor"(%14, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.or"(%11, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.umin"(%16, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "2_1206_18"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.set_high_bits"(%3, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.set_sign_bit"(%1) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.neg"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.shl"(%6, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.make"(%8, %7) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %9 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_138_76"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.clear_sign_bit"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%5, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.cmp"(%7, %3) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = arith.xori %9, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %10 : i1
  }
  func.func @partial_solution_9_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_1194_81"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.umin"(%7, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.udiv"(%4, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.umin"(%6, %8) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.clear_high_bits"(%5, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.set_low_bits"(%3, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.set_sign_bit"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.smax"(%13, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.countr_zero"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %16 = "transfer.udiv"(%2, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.shl"(%14, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_1498_84"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smax"(%4, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%6, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.cmp"(%6, %3) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = arith.ori %8, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %10 = arith.xori %7, %9 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %10 : i1
  }
  func.func @partial_solution_10_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "3_766_44"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.clear_high_bits"(%2, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.set_sign_bit"(%5) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.ashr"(%2, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.or"(%6, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.neg"(%7) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.urem"(%10, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_low_bits"(%1, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_10_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "4_174_80"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smin"(%3, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.udiv"(%3, %6) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%5, %7) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %8 : i1
  }
  func.func @partial_solution_11_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "3_525_64"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%4, %2) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.select"(%8, %7, %5) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.umax"(%10, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.set_high_bits"(%11, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%6, %7) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.set_low_bits"(%12, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.mul"(%2, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.smin"(%14, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.clear_high_bits"(%16, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.make"(%17, %16) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %18 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_12_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_1126_69"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_one"(%4) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.or"(%3, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.lshr"(%3, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.cmp"(%7, %8) {predicate = 6 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %12 = "transfer.set_high_bits"(%1, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.countl_zero"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.shl"(%10, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.select"(%11, %6, %6) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.set_low_bits"(%2, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.smax"(%12, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.add"(%16, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.mul"(%14, %18) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.clear_high_bits"(%19, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %21 = "transfer.sdiv"(%17, %20) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %22 = "transfer.clear_high_bits"(%12, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %23 = "transfer.make"(%22, %21) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %23 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_13_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "1_1216_4"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.umin"(%3, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.countr_one"(%6) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.shl"(%1, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_high_bits"(%8, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.shl"(%2, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_high_bits"(%10, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_13_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "3_984_88"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %6 = "transfer.constant"(%5) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%5, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.cmp"(%5, %4) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = arith.andi %7, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %10 = "transfer.cmp"(%3, %2) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = arith.andi %9, %10 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %11 : i1
  }
  func.func @partial_solution_14_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_412_35"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_zero"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.smax"(%6, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.and"(%5, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.sub"(%2, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.set_high_bits"(%3, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.and"(%12, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%8, %9) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.add"(%6, %13) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.or"(%16, %14) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.shl"(%1, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_14_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_1135_88"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.shl"(%2, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%2, %5) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_15_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_579_63"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_zero"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%3, %4) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.countl_one"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.set_sign_bit"(%1) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.add"(%7, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.select"(%8, %5, %11) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.clear_low_bits"(%4, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.lshr"(%10, %12) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.set_high_bits"(%14, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.shl"(%13, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.make"(%16, %15) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %17 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_16_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "2_1303_48"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.countr_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.shl"(%2, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%7, %6) {predicate = 7 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.select"(%10, %5, %9) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_sign_bit"(%1) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.set_sign_bit"(%11) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.or"(%12, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.make"(%14, %13) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %15 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_17_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "3_864_7"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.add"(%7, %7) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.set_high_bits"(%2, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.or"(%10, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.cmp"(%9, %8) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %13 = "transfer.sdiv"(%6, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%2, %13) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.select"(%12, %14, %4) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.smin"(%11, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.neg"(%16) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %18 = "transfer.lshr"(%15, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_17_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "4_566_84"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%2, %3) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %7 = "transfer.cmp"(%2, %5) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = arith.ori %7, %6 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %8 : i1
  }
  func.func @partial_solution_18_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_885_51"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.constant"(%4) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%4) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countr_one"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.umin"(%1, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_zero"(%8) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.umax"(%6, %9) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.shl"(%2, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_low_bits"(%2, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_18_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_1192_84"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.shl"(%2, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%5, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_19_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_715_54"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.umin"(%1, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.sdiv"(%7, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_zero"(%8) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.lshr"(%2, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.set_low_bits"(%1, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.smin"(%4, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_0_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_1_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_2_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_3_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_4_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_5_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_6_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_7_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
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
  func.func @partial_solution_9(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
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
  func.func @partial_solution_10(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_10_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_10_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_11(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_11_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_12(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_12_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_13(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
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
  func.func @partial_solution_14(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
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
  func.func @partial_solution_15(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_15_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_16(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_16_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_17(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_17_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_17_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_18(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_18_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_18_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_19(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_19_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
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
    %18 = func.call @partial_solution_16(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %19 = func.call @partial_solution_17(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %20 = func.call @partial_solution_18(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %21 = func.call @partial_solution_19(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %22 = func.call @meet(%2, %3) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %23 = func.call @meet(%22, %4) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %24 = func.call @meet(%23, %5) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %25 = func.call @meet(%24, %6) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %26 = func.call @meet(%25, %7) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %27 = func.call @meet(%26, %8) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %28 = func.call @meet(%27, %9) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %29 = func.call @meet(%28, %10) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %30 = func.call @meet(%29, %11) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %31 = func.call @meet(%30, %12) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %32 = func.call @meet(%31, %13) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %33 = func.call @meet(%32, %14) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %34 = func.call @meet(%33, %15) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %35 = func.call @meet(%34, %16) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %36 = func.call @meet(%35, %17) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %37 = func.call @meet(%36, %18) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %38 = func.call @meet(%37, %19) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %39 = func.call @meet(%38, %20) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %40 = func.call @meet(%39, %21) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %40 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
}
