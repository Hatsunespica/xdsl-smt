builtin.module {
  func.func @partial_solution_0_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, number = "0_887_15"} {
    %1 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.constant"(%1) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %3 = "transfer.get_bit_width"(%1) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.umin"(%3, %2) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %5 = "transfer.lshr"(%1, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.countl_zero"(%5) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.clear_low_bits"(%5, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.umin"(%7, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.make"(%8, %7) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %9 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, from_weighted_dsl, number = "1_902_44"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.sdiv"(%2, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.udiv"(%1, %5) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.shl"(%3, %4) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.countl_zero"(%7) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %9 = "transfer.neg"(%6) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %10 = "transfer.clear_low_bits"(%6, %8) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%10, %9) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_70_72"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.set_sign_bit"(%3) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.sdiv"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%5, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_2_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, from_weighted_dsl, number = "1_544_36"} {
    %1 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.srem"(%3, %3) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.sdiv"(%5, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.cmp"(%6, %7) {predicate = 6 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %11 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %12 = "transfer.set_sign_bit"(%9) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %13 = "transfer.set_high_bits"(%8, %11) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.ashr"(%12, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.select"(%10, %5, %4) {ret_type = "int", input_type = ["bool", "int", "int"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.sdiv"(%13, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.umin"(%13, %14) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.shl"(%16, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, number = "0_1332_2"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.countl_one"(%1) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.sub"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.smin"(%5, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countl_zero"(%3) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.cmp"(%8, %9) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    %12 = "transfer.select"(%11, %6, %10) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.ashr"(%9, %12) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.countr_one"(%13) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %15 = "transfer.sub"(%14, %7) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.set_low_bits"(%8, %12) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.srem"(%5, %16) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.clear_low_bits"(%5, %15) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_1002_84"} {
    %2 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.constant"(%2) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%2) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.sdiv"(%2, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %6 = "transfer.cmp"(%5, %3) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %6 : i1
  }
  func.func @partial_solution_4_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, number = "1_1378_17"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.sub"(%5, %6) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.xor"(%2, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.smax"(%4, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.countl_zero"(%2) {ret_type = "bint", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %11 = "transfer.set_low_bits"(%8, %7) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.umax"(%5, %10) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.umax"(%12, %7) {ret_type = "bint", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.lshr"(%2, %10) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.ashr"(%14, %13) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.srem"(%11, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %17 = "transfer.umin"(%16, %15) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %18 = "transfer.neg"(%15) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %19 = "transfer.make"(%18, %17) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %19 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "2_195_93"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.neg"(%3) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.cmp"(%4, %2) {predicate = 6 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %5 : i1
  }
  func.func @partial_solution_5_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, number = "0_864_40"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = "transfer.get_all_ones"(%4) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.get_bit_width"(%4) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.lshr"(%1, %6) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %8 = "transfer.udiv"(%3, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.sdiv"(%8, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.urem"(%5, %9) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.smin"(%7, %1) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.make"(%11, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %12 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_455_90"} {
    %2 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get_all_ones"(%3) {ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.ashr"(%2, %5) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.cmp"(%4, %6) {predicate = 7 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %7 : i1
  }
  func.func @partial_solution_6_body(%arg0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true, number = "0_1407_45"} {
    %1 = "transfer.get"(%arg0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %2 = "transfer.get"(%arg0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%0) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 0 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.constant"(%3) {value = 1 : index, ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %7 = "transfer.get_bit_width"(%3) {ret_type = "bint"} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.cmp"(%6, %7) {predicate = 0 : index, ret_type = "bool", input_type = ["bint", "bint"]} : (!transfer.integer, !transfer.integer) -> i1
    %9 = "transfer.select"(%8, %5, %7) {ret_type = "bint", input_type = ["bool", "bint", "bint"]} : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.lshr"(%4, %9) {ret_type = "int", input_type = ["int", "bint"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.or"(%2, %10) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %12 = "transfer.sdiv"(%4, %11) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %13 = "transfer.xor"(%12, %4) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %14 = "transfer.udiv"(%13, %12) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %15 = "transfer.srem"(%1, %14) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %16 = "transfer.make"(%15, %14) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %16 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_6_cond(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1 attributes {number = "1_252_93"} {
    %2 = "transfer.get"(%0) {index = 0 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %3 = "transfer.get"(%1) {index = 1 : index, ret_type = "int"} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.constant"(%3) {value = 0 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %5 = "transfer.constant"(%3) {value = 1 : index, ret_type = "int"} : (!transfer.integer) -> !transfer.integer
    %6 = "transfer.smax"(%5, %2) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %7 = "transfer.neg"(%2) {ret_type = "int", input_type = ["int"]} : (!transfer.integer) -> !transfer.integer
    %8 = "transfer.urem"(%6, %7) {ret_type = "int", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %9 = "transfer.cmp"(%8, %4) {predicate = 0 : index, ret_type = "bool", input_type = ["int", "int"]} : (!transfer.integer, !transfer.integer) -> i1
    func.return %9 : i1
  }
  func.func @partial_solution_0(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @partial_solution_0_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_1(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_1_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_1_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_2(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @partial_solution_2_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %2 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_3(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_3_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_3_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_4(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_4_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_4_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
    %9 = "transfer.select"(%8, %6, %3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %10 = "transfer.select"(%8, %7, %4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %11 = "transfer.make"(%9, %10) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %11 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
  func.func @partial_solution_5(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
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
  func.func @partial_solution_6(%0 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %1 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]> attributes {applied_to = ["comb.shrs"], CPPCLASS = ["circt::comb::SHRSOp"], is_forward = true} {
    %2 = func.call @getTop(%0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %3 = "transfer.get"(%2) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %4 = "transfer.get"(%2) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %5 = func.call @partial_solution_6_body(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %6 = "transfer.get"(%5) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %7 = "transfer.get"(%5) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %8 = func.call @partial_solution_6_cond(%0, %1) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1
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
    %9 = func.call @meet(%2, %3) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %10 = func.call @meet(%9, %4) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %11 = func.call @meet(%10, %5) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %12 = func.call @meet(%11, %6) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %13 = func.call @meet(%12, %7) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    %14 = func.call @meet(%13, %8) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %14 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }
}
