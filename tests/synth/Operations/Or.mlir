"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>, sym_name = "ORImpl", applied_to=["comb.or"], CPPCLASS=["circt::comb::OrOp"], is_forward=true} : () -> ()
}): () -> ()
