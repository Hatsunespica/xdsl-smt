"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

    %cl0 = "transfer.countl_zero"(%arg0) : (!transfer.integer) -> !transfer.integer
    %cl1 = "transfer.countl_one"(%arg0) : (!transfer.integer) -> !transfer.integer
    %is_non_neg = "transfer.cmp"(%arg0, %const0) {predicate=5:i64}: (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl0 = "transfer.cmp"(%arg1, %cl0) {predicate=6:i64}: (!transfer.integer, !transfer.integer) -> i1
    %shamt_lt_cl1 = "transfer.cmp"(%arg1, %cl1) {predicate=6:i64}: (!transfer.integer, !transfer.integer) -> i1
    %nsw = "transfer.select"(%is_non_neg, %shamt_lt_cl0, %shamt_lt_cl1): (i1, i1, i1) -> i1

    %res = "arith.andi"(%check, %nsw) : (i1, i1) -> i1
    "func.return"(%res) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %3 = "transfer.get"(%arg1) {"index" = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %6 = "transfer.constant"(%3) {"value" = 0 : index} : (!transfer.integer) -> !transfer.integer
    %29 = "transfer.make"(%6, %6) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    func.return %29 : !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "SHLImpl", applied_to=["comb.shl"], CPPCLASS=["circt::comb::SHLOp"], is_forward=true} : () -> ()
}) : () -> ()
