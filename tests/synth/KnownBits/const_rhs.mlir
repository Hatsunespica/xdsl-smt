"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
  %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
  %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
  %add_res = "transfer.add"(%arg00, %arg01) : (!transfer.integer,!transfer.integer) -> !transfer.integer
  %all_ones = "transfer.get_all_ones"(%arg01) : (!transfer.integer) -> !transfer.integer
  %cmp_res = "transfer.cmp"(%add_res,%all_ones){predicate=0:i64}:(!transfer.integer,!transfer.integer)->i1
  "func.return"(%cmp_res) : (i1) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> i1, sym_name = "abs_op_constraint"} : () -> ()
