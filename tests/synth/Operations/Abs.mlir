"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer):
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %one="transfer.constant"(%arg0){value=1:index}:(!transfer.integer)->!transfer.integer
    %two="transfer.constant"(%arg0){value=2:index}:(!transfer.integer)->!transfer.integer
    %bit_sub_one = "transfer.sub"(%bitwidth, %one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %ashr = "transfer.ashr"(%arg0, %bit_sub_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %and_one = "transfer.and"(%ashr, %one) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %mul_two = "transfer.mul"(%and_one, %two) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %minus = "transfer.sub"(%one, %mul_two) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %result = "transfer.mul"(%arg0, %minus) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SMinImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
