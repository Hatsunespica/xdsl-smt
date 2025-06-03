"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %ori = "transfer.or"(%arg0, %arg1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %xori = "transfer.xor"(%arg0, %arg1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %one = "transfer.constant"(%arg0){value=1:index} : (!transfer.integer) -> !transfer.integer
    %ashri = "transfer.ashr"(%xori, %one) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %result = "transfer.sub"(%ori, %ashri) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "AvgCeilSImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
