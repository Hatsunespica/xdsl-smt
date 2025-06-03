"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %andi = "transfer.and"(%arg0, %arg1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %xori = "transfer.xor"(%arg0, %arg1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %one = "transfer.constant"(%arg0){value=1:index} : (!transfer.integer) -> !transfer.integer
    %lshri = "transfer.lshr"(%xori, %one) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %result = "transfer.add"(%andi, %lshri) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "UMaxImpl", applied_to=["comb.umax"], CPPCLASS=["circt::comb::UMaxOp"], is_forward=true} : () -> ()
}): () -> ()
