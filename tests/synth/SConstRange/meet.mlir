"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
  %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %arg10 = "transfer.get"(%arg1) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %arg11 = "transfer.get"(%arg1) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %min = "transfer.smax"(%arg00,%arg10): (!transfer.integer, !transfer.integer)->!transfer.integer
  %max = "transfer.smin"(%arg01,%arg11): (!transfer.integer, !transfer.integer)->!transfer.integer
  %result = "transfer.make"(%min, %max) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>, sym_name = "meet"} : () -> ()
