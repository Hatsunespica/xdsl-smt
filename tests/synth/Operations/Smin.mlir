"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %add = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %sub = "transfer.sub"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %one="transfer.constant"(%arg0){value=1:index}:(!transfer.integer)->!transfer.integer
    %bit_sub_one = "transfer.sub"(%bitwidth, %one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %ashr = "transfer.ashr"(%sub, %bit_sub_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %and_one = "transfer.and"(%ashr, %one) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %mul = "transfer.mul"(%and_one, %sub) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %min = "transfer.sub"(%arg0, %mul) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %result = "transfer.sub"(%add, %min) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SMinImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
