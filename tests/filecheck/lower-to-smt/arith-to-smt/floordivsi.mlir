// RUN: xdsl-smt %s -p=lower-to-smt,lower-effects,canonicalize-smt | filecheck %s
// RUN: xdsl-smt %s -p=lower-to-smt,lower-effects,canonicalize-smt -t=smt | z3 -in

"builtin.module"() ({
  "func.func"() ({
  ^0(%x : i32, %y : i32):
    %r = "arith.floordivsi"(%x, %y) : (i32, i32) -> i32
    "func.return"(%r) : (i32) -> ()
  }) {"sym_name" = "test", "function_type" = (i32, i32) -> i32, "sym_visibility" = "private"} : () -> ()
}) : () -> ()

// CHECK:       builtin.module {
// CHECK-NEXT:    %0 = "smt.define_fun"() ({
// CHECK-NEXT:    ^0(%x : !smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, %y : !smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, %1 : !smt.bool):
// CHECK-NEXT:      %2 = "smt.utils.first"(%x) : (!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %3 = "smt.utils.second"(%x) : (!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>) -> !smt.bool
// CHECK-NEXT:      %4 = "smt.utils.first"(%y) : (!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %5 = "smt.utils.second"(%y) : (!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>) -> !smt.bool
// CHECK-NEXT:      %6 = "smt.or"(%3, %5) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %7 = "smt.bv.constant"() {"value" = #smt.bv.bv_val<2147483648: 32>} : () -> !smt.bv.bv<32>
// CHECK-NEXT:      %8 = "smt.bv.constant"() {"value" = #smt.bv.bv_val<4294967295: 32>} : () -> !smt.bv.bv<32>
// CHECK-NEXT:      %9 = "smt.eq"(%2, %7) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %10 = "smt.eq"(%4, %8) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %11 = "smt.and"(%9, %10) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %12 = "smt.bv.constant"() {"value" = #smt.bv.bv_val<0: 32>} : () -> !smt.bv.bv<32>
// CHECK-NEXT:      %13 = "smt.eq"(%12, %4) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %14 = "smt.or"(%11, %13) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %15 = "smt.bv.sdiv"(%2, %4) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %16 = "smt.bv.slt"(%2, %12) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %17 = "smt.bv.slt"(%4, %12) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %18 = "smt.xor"(%16, %17) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %19 = "smt.bv.srem"(%2, %4) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %20 = "smt.distinct"(%19, %12) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bool
// CHECK-NEXT:      %21 = "smt.bv.add"(%15, %8) : (!smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %22 = "smt.and"(%18, %20) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %23 = "smt.ite"(%22, %21, %15) : (!smt.bool, !smt.bv.bv<32>, !smt.bv.bv<32>) -> !smt.bv.bv<32>
// CHECK-NEXT:      %24 = "smt.or"(%14, %6) : (!smt.bool, !smt.bool) -> !smt.bool
// CHECK-NEXT:      %r = "smt.utils.pair"(%23, %24) : (!smt.bv.bv<32>, !smt.bool) -> !smt.utils.pair<!smt.bv.bv<32>, !smt.bool>
// CHECK-NEXT:      %25 = "smt.utils.pair"(%r, %1) : (!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.bool) -> !smt.utils.pair<!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.bool>
// CHECK-NEXT:      "smt.return"(%25) : (!smt.utils.pair<!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.bool>) -> ()
// CHECK-NEXT:    }) {"fun_name" = "test"} : () -> ((!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.bool) -> !smt.utils.pair<!smt.utils.pair<!smt.bv.bv<32>, !smt.bool>, !smt.bool>)
// CHECK-NEXT:  }
