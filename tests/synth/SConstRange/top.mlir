"func.func"() ({
^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer]>):
  %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
  %min = "transfer.get_signed_min_value"(%arg00){value=0:index} : (!transfer.integer) -> !transfer.integer
  %max = "transfer.get_signed_max_value"(%arg00){value=0:index} : (!transfer.integer) -> !transfer.integer
  %result = "transfer.make"(%min, %max) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
  "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>, sym_name = "getTop"} : () -> ()
