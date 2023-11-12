// RUN: xdsl-smt "%s" -p=lower-to-smt,canonicalize-smt -t=smt | filecheck "%s"
// RUN: xdsl-smt %s -p=lower-to-smt,canonicalize-smt -t=smt | z3 -in

builtin.module {
  func.func @test(%x : i32) -> i64 {
    %r = arith.extui %x : i32 to i64
    "func.return"(%r) : (i64) -> ()
  }
}

// CHECK:       (declare-datatypes ((Pair 2)) ((par (X Y) ((pair (first X) (second Y))))))
// CHECK-NEXT:  (define-fun test ((x (Pair (_ BitVec 32) Bool))) (Pair (_ BitVec 64) Bool)
// CHECK-NEXT:    (pair (concat (_ bv0 32) (first x)) (second x)))
