"func.func"() ({
^bb0(%arg: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
  %top = "func.call"(%arg) {callee = @getTop} : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>

  %arg0 = "transfer.get"(%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top0 = "transfer.get"(%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res0 = "transfer.cmp"(%top0, %arg0) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %arg1 = "transfer.get"(%arg) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top1 = "transfer.get"(%top) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res1 = "transfer.cmp"(%top1, %arg1) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %arg2 = "transfer.get"(%arg) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top2 = "transfer.get"(%top) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res2 = "transfer.cmp"(%top2, %arg2) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %arg3 = "transfer.get"(%arg) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top3 = "transfer.get"(%top) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res3 = "transfer.cmp"(%top3, %arg3) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %arg4 = "transfer.get"(%arg) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top4 = "transfer.get"(%top) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res4 = "transfer.cmp"(%top4, %arg4) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %arg5 = "transfer.get"(%arg) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top5 = "transfer.get"(%top) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %res5 = "transfer.cmp"(%top5, %arg5) {predicate = 7} : (!transfer.integer, !transfer.integer) -> i1

  %res01 = "transfer.and"(%res0, %res1) : (i1, i1) -> i1
  %res012 = "transfer.and"(%res01, %res2) : (i1, i1) -> i1
  %res0123 = "transfer.and"(%res012, %res3) : (i1, i1) -> i1
  %res01234 = "transfer.and"(%res0123, %res4) : (i1, i1) -> i1
  %res012345 = "transfer.and"(%res01234, %res5) : (i1, i1) -> i1
  "func.return"(%res012345) : (i1) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> i1, sym_name = "getConstraint"} : () -> ()
