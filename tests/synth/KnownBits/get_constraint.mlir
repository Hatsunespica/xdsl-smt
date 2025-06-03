"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
  %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %andi = "transfer.and"(%arg00, %arg01) : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %const0 = "transfer.constant"(%arg00){value=0:index} : (!transfer.integer) -> !transfer.integer
  %result = "transfer.cmp"(%andi, %const0){predicate=0:i64}:(!transfer.integer, !transfer.integer) -> i1
  "func.return"(%result) : (i1) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> i1, sym_name = "getConstraint"} : () -> ()
