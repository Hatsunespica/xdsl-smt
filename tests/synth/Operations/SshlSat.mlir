"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %signed_max = "transfer.get_signed_max_value"(%arg0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%arg0) : (!transfer.integer) -> !transfer.integer
    %shlRes = "transfer.shl"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %overflow = "transfer.sshl_overflow"(%arg0, %arg1) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg0_is_neg = "transfer.is_negative"(%arg0): (!transfer.integer) -> i1
    %sat_res = "transfer.select"(%arg0_is_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) ->!transfer.integer
    %result = "transfer.select"(%overflow, %sat_res, %shlRes) : (i1, !transfer.integer, !transfer.integer) ->!transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SShlSatImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
