// RUN: xdsl-synth %S/with-synth-input.mlir %S/with-synth-output.mlir | filecheck "%s"

// This file uses `with-synth-output.mlir`

builtin.module {
  func.func @test(%arg0 : i32) -> i32 {
    %c = smt.synth.constant : i32
    %r = arith.shli %arg0, %c : i32
    func.return %r : i32
  }
}
