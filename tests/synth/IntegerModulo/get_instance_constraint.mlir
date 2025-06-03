"func.func"() ({
^bb0(%arg: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, %inst: !transfer.integer):
  %top = "func.call"(%arg) {callee = @getTop} : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>

  %arg0 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %zero = "transfer.constant"(%arg0){value=0:index} : (!transfer.integer) -> !transfer.integer
  %top0 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt0 = "transfer.cmp" (%arg0, %top0){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub0 = "transfer.sub" (%inst, %arg0)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod0 = "transfer.urem"(%sub0, %top0)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm0 = "transfer.cmp" (%mod0, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res0 = "transfer.or"(%eqt0, %eqm0): (i1, i1) -> i1

  %arg1 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top1 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt1 = "transfer.cmp" (%arg1, %top1){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub1 = "transfer.sub" (%inst, %arg1)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod1 = "transfer.urem"(%sub1, %top1)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm1 = "transfer.cmp" (%mod1, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res1 = "transfer.or"(%eqt1, %eqm1): (i1, i1) -> i1

  %arg2 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top2 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt2 = "transfer.cmp" (%arg2, %top2){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub2 = "transfer.sub" (%inst, %arg2)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod2 = "transfer.urem"(%sub2, %top2)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm2 = "transfer.cmp" (%mod2, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res2 = "transfer.or"(%eqt2, %eqm2): (i1, i1) -> i1

  %arg3 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top3 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt3 = "transfer.cmp" (%arg3, %top3){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub3 = "transfer.sub" (%inst, %arg3)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod3 = "transfer.urem"(%sub3, %top3)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm3 = "transfer.cmp" (%mod3, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res3 = "transfer.or"(%eqt3, %eqm3): (i1, i1) -> i1

  %arg4 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top4 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt4 = "transfer.cmp" (%arg4, %top4){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub4 = "transfer.sub" (%inst, %arg4)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod4 = "transfer.urem"(%sub4, %top4)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm4 = "transfer.cmp" (%mod4, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res4 = "transfer.or"(%eqt4, %eqm4): (i1, i1) -> i1

  %arg5 = "transfer.get" (%arg) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top5 = "transfer.get" (%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %eqt5 = "transfer.cmp" (%arg5, %top5){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %sub5 = "transfer.sub" (%inst, %arg5)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %mod5 = "transfer.urem"(%sub5, %top5)             : (!transfer.integer, !transfer.integer) -> !transfer.integer
  %eqm5 = "transfer.cmp" (%mod5, %zero){predicate=0}: (!transfer.integer, !transfer.integer) -> i1
  %res5 = "transfer.or"(%eqt5, %eqm5): (i1, i1) -> i1

  %res01 = "transfer.and"(%res0, %res1) : (i1, i1) -> i1
  %res012 = "transfer.and"(%res01, %res2) : (i1, i1) -> i1
  %res0123 = "transfer.and"(%res012, %res3) : (i1, i1) -> i1
  %res01234 = "transfer.and"(%res0123, %res4) : (i1, i1) -> i1
  %res012345 = "transfer.and"(%res01234, %res5) : (i1, i1) -> i1
  "func.return"(%res012345) : (i1) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, !transfer.integer) -> i1, sym_name = "getInstanceConstraint"} : () -> ()
