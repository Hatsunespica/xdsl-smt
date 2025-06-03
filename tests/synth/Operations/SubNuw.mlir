"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %check = "transfer.cmp"(%arg0, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    "func.return"(%check) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SubImpl", applied_to=["comb.sub"], CPPCLASS=["circt::comb::SubOp"], is_forward=true} : () -> ()
}): () -> ()
