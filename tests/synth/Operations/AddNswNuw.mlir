"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %sum = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sum_ge_arg0 = "transfer.cmp"(%sum, %arg0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %sum_ge_arg1 = "transfer.cmp"(%sum, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %nuw = "arith.andi"(%sum_ge_arg0, %sum_ge_arg1) : (i1, i1) -> i1

    %xor0 = "transfer.xor"(%arg0, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor1 = "transfer.xor"(%arg1, %sum) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %andres = "transfer.and"(%xor0, %xor1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %zero = "transfer.constant"(%arg0){value=0:index} : (!transfer.integer) -> !transfer.integer
    %nsw = "transfer.cmp"(%andres, %zero) {predicate=5:i64}: (!transfer.integer, !transfer.integer) -> i1

    %check = "arith.andi"(%nuw, %nsw) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "AddImpl", applied_to=["comb.add"], CPPCLASS=["circt::comb::AddOp"], is_forward=true} : () -> ()
}): () -> ()
