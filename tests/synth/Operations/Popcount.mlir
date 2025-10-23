"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer):
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %val0="transfer.constant"(%arg0){value=0:index}:(!transfer.integer)->!transfer.integer
    %val1="transfer.constant"(%arg0){value=1:index}:(!transfer.integer)->!transfer.integer
    %val2="transfer.constant"(%arg0){value=2:index}:(!transfer.integer)->!transfer.integer
    %val3="transfer.constant"(%arg0){value=3:index}:(!transfer.integer)->!transfer.integer
    %val4="transfer.constant"(%arg0){value=4:index}:(!transfer.integer)->!transfer.integer
    %val5="transfer.constant"(%arg0){value=5:index}:(!transfer.integer)->!transfer.integer
    %val6="transfer.constant"(%arg0){value=6:index}:(!transfer.integer)->!transfer.integer
    %val7="transfer.constant"(%arg0){value=7:index}:(!transfer.integer)->!transfer.integer
    %lshr0="transfer.lshr"(%arg0, %val0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr1="transfer.lshr"(%arg0, %val1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr2="transfer.lshr"(%arg0, %val2) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr3="transfer.lshr"(%arg0, %val3) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr4="transfer.lshr"(%arg0, %val4) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr5="transfer.lshr"(%arg0, %val5) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr6="transfer.lshr"(%arg0, %val6) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %lshr7="transfer.lshr"(%arg0, %val7) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %and0="transfer.and"(%lshr0, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and1="transfer.and"(%lshr1, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and2="transfer.and"(%lshr2, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and3="transfer.and"(%lshr3, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and4="transfer.and"(%lshr4, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and5="transfer.and"(%lshr5, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and6="transfer.and"(%lshr6, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and7="transfer.and"(%lshr7, %val0) : (!transfer.integer,!transfer.integer) -> !transfer.integer

    %res ="transfer.add"(%and0, %and1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res2 ="transfer.add"(%and2, %res) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res3 ="transfer.add"(%and3, %res2) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res4 ="transfer.add"(%and4, %res3) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res5 ="transfer.add"(%and5, %res4) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res6 ="transfer.add"(%and6, %res5) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %res7 ="transfer.add"(%and7, %res6) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    "func.return"(%res7) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer) -> !transfer.integer, sym_name = "concrete_op"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SMinImpl", applied_to=["comb.xxx"], CPPCLASS=["circt::comb::XXXOp"], is_forward=true} : () -> ()
}): () -> ()
