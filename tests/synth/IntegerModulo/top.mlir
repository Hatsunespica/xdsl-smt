"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
  %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %c2 = "transfer.constant" (%arg00){value=2:index}  : (!transfer.integer) -> !transfer.integer
  %c3 = "transfer.constant" (%arg00){value=3:index}  : (!transfer.integer) -> !transfer.integer
  %c5 = "transfer.constant" (%arg00){value=5:index}  : (!transfer.integer) -> !transfer.integer
  %c7 = "transfer.constant" (%arg00){value=7:index}  : (!transfer.integer) -> !transfer.integer
  %c11 = "transfer.constant"(%arg00){value=11:index} : (!transfer.integer) -> !transfer.integer
  %c13 = "transfer.constant"(%arg00){value=13:index} : (!transfer.integer) -> !transfer.integer
  %top = "transfer.make"(%c2, %c3, %c5, %c7, %c11, %c13) : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>
  "func.return"(%top) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, sym_name = "getTop"} : () -> ()
