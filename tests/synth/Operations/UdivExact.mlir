"builtin.module"() ({
  "func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %const1 = "transfer.constant"(%arg1) {value=1:index}:(!transfer.integer)->!transfer.integer
    %arg1_neq_0 = "transfer.cmp"(%const0, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1

    %safe_arg1 = "transfer.select"(%arg1_neq_0, %arg1, %const1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %rem = "transfer.urem"(%arg0, %safe_arg1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %exact = "transfer.cmp"(%rem, %const0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1

    %check = "arith.andi"(%exact, %arg1_neq_0) : (i1, i1) -> i1
    "func.return"(%check) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "UDIVImpl", applied_to=["comb.divu"], CPPCLASS=["circt::comb::UDIVOp"], is_forward=true} : () -> ()
}) : () -> ()
