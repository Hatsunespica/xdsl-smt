"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %inst: !transfer.integer):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %cmp1 = "transfer.cmp"(%arg00, %inst){predicate=3:i64}:(!transfer.integer, !transfer.integer) -> i1
    %cmp2="transfer.cmp"(%inst,%arg01){predicate=3:i64}:(!transfer.integer, !transfer.integer) -> i1
    %result="arith.andi"(%cmp1,%cmp2):(i1,i1)->i1
    "func.return"(%result) : (i1) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.integer) -> i1, sym_name = "getInstanceConstraint"} : () -> ()
