"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %bitwidth = "transfer.get_bit_width"(%arg0): (!transfer.integer) -> !transfer.integer
    %arg1_ge_0 = "transfer.cmp"(%arg1, %const0) {predicate=9:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg1_le_bitwidth = "transfer.cmp"(%arg1, %bitwidth) {predicate=7:i64}: (!transfer.integer, !transfer.integer) -> i1
    %check = "arith.andi"(%arg1_ge_0, %arg1_le_bitwidth) : (i1, i1) -> i1

    %tmp1 = "transfer.lshr"(%arg0, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %tmp2 = "transfer.shl"(%tmp1, %arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %eq = "transfer.cmp"(%tmp2, %arg0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

    %ret = "arith.andi"(%check, %eq) : (i1, i1) -> i1
    "func.return"(%ret) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "LSHRImpl", applied_to=["comb.shru"], CPPCLASS=["circt::comb::SHRUOp"], is_forward=true} : () -> ()
}) : () -> ()
