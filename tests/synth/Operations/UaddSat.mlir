"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):

    %const0 = "transfer.constant"(%arg0){value=0:index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%arg0){value=1:index} : (!transfer.integer) -> !transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %bitwidth_minus_one = "transfer.sub"(%bitwidth, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %add = "transfer.add"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %sub = "transfer.sub"(%add, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor = "transfer.xor"(%add, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_neg_tmp="transfer.sub"(%const0, %xor): (!transfer.integer, !transfer.integer) -> !transfer.integer
    %xor_neg="transfer.sub"(%xor_neg_tmp, %const1): (!transfer.integer, !transfer.integer) -> !transfer.integer
    %and = "transfer.and"(%sub, %xor_neg) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    %add_neg_tmp ="transfer.sub"(%const0, %add): (!transfer.integer, !transfer.integer) -> !transfer.integer
    %add_neg="transfer.sub"(%add_neg_tmp, %const1): (!transfer.integer, !transfer.integer) -> !transfer.integer

    %and_neg_add_arg1 = "transfer.and"(%add_neg, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %or  = "transfer.or"(%and_neg_add_arg1, %and) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr  = "transfer.lshr"(%or, %bitwidth_minus_one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %overflow = "transfer.and"(%lshr, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mask = "transfer.sub"(%const0, %overflow) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %result = "transfer.or"(%add, %mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%result) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer,!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "UAddSatImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
