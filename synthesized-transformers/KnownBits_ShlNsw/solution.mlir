builtin.module {
  func.func @partial_solution_0_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "0_434_22"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_zero"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.umin"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_high_bits"(%4, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.umax"(%7, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.shl"(%1, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.countl_one"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.xor"(%12, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.add"(%8, %11) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.cmp"(%7, %13) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %17 = "transfer.select"(%16, %15, %5) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.lshr"(%9, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.ashr"(%14, %17) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %20 = "transfer.make"(%19, %18) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "1_463_44"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%6, %7) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = "transfer.countl_zero"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.lshr"(%5, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_high_bits"(%5, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.countl_zero"(%11) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %14 = "transfer.select"(%9, %1, %12) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.set_low_bits"(%14, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.set_sign_bit"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %17 = "transfer.and"(%16, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.neg"(%15) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "0_1458_18"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.countr_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.sub"(%2, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.add"(%5, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_zero"(%5) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.clear_low_bits"(%6, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.set_low_bits"(%6, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.make"(%9, %8) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %10 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "4_144_34"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.neg"(%1) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.countr_zero"(%4) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.umin"(%5, %3) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.clear_low_bits"(%1, %3) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.shl"(%2, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.make"(%8, %7) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %9 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "0_1121_42"} {
    %1 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.lshr"(%2, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.urem"(%2, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.clear_high_bits"(%6, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_zero"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_high_bits"(%6, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.clear_low_bits"(%8, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.add"(%10, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "0_93_26"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.and"(%3, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.add"(%2, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.xor"(%4, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.add"(%1, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.make"(%7, %6) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %8 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_83_75"} {
    %2 = "transfer.get"(%1) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.clear_low_bits"(%2, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%2, %4) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %8 = "transfer.cmp"(%5, %5) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.cmp"(%4, %6) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %10 = arith.xori %9, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %11 = arith.andi %7, %8 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    %12 = arith.andi %11, %10 {ret_type = "bool", input_type = ["bool", "bool"]} : i1
    func.return %12 : i1
  }
  func.func @partial_solution_6_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_1325_77"} {
    %1 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.constant"(%1) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %3 = "transfer.add"(%2, %2) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %4 = "transfer.umin"(%1, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.countl_one"(%4) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.lshr"(%1, %2) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.clear_sign_bit"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.umax"(%5, %3) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.add"(%8, %8) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.add"(%9, %2) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.clear_low_bits"(%7, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.or"(%6, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.make"(%12, %11) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %13 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, number = "3_27_14"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.constant"(%2) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.countr_zero"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.and"(%2, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.umin"(%4, %5) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.umin"(%5, %8) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.ashr"(%7, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.umin"(%7, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.srem"(%2, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.shl"(%11, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.make"(%13, %12) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %14 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "0_203_78"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.umin"(%1, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.set_sign_bit"(%4) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.shl"(%6, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.udiv"(%7, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countl_zero"(%8) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.countr_zero"(%9) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.ashr"(%3, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.lshr"(%12, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.make"(%13, %12) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %14 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true, from_weighted_dsl, number = "3_38_64"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_bit_width"(%2) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.clear_sign_bit"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.clear_sign_bit"(%3) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_zero"(%6) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.lshr"(%3, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.countl_zero"(%5) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.and"(%6, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.sub"(%8, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.clear_low_bits"(%10, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.lshr"(%11, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.lshr"(%13, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.srem"(%12, %8) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.add"(%14, %13) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.make"(%16, %15) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %17 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
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
  func.func @partial_solution_6(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_6_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_7(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_7_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_8(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_8_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_9(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shl"], CPPCLASS = ["circt::comb::SHLOp"], is_forward = true} {
    %2 = func.call @partial_solution_9_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
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
    %12 = func.call @meet(%2, %3) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %13 = func.call @meet(%12, %4) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %14 = func.call @meet(%13, %5) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %15 = func.call @meet(%14, %6) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %16 = func.call @meet(%15, %7) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %17 = func.call @meet(%16, %8) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %18 = func.call @meet(%17, %9) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %19 = func.call @meet(%18, %10) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %20 = func.call @meet(%19, %11) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %20 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
}
