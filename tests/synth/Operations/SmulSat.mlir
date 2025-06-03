"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %signed_max = "transfer.get_signed_max_value"(%arg0) : (!transfer.integer) -> !transfer.integer
    %signed_min = "transfer.get_signed_min_value"(%arg0) : (!transfer.integer) -> !transfer.integer
    %mulRes = "transfer.mul"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %arg0_is_neg = "transfer.is_negative"(%arg0): (!transfer.integer) -> i1
    %arg1_is_neg = "transfer.is_negative"(%arg1): (!transfer.integer) -> i1
    %res_is_neg = "arith.xor"(%arg0_is_neg, %arg1_is_neg): (i1,i1) -> i1
    %sat_res = "transfer.select"(%res_is_neg, %signed_min, %signed_max) : (i1, !transfer.integer, !transfer.integer) ->!transfer.integer
    %overflow = "transfer.smul_overflow"(%arg0, %arg1){predicate=6:i64}:(!transfer.integer,!transfer.integer)->i1
    %result = "transfer.select"(%overflow, %sat_res, %mulRes) : (i1, !transfer.integer, !transfer.integer) ->!transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "UMULSatImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
