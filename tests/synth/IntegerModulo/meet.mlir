"func.func"() ({
^bb0(%lhs: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, %rhs: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
  %top = "func.call"(%lhs) {callee = @getTop} : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>

  %bot_arg = "transfer.get"(%lhs) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %bot0 = "transfer.constant"(%bot_arg){value=3:index} : (!transfer.integer) -> !transfer.integer
  %bot1 = "transfer.constant"(%bot_arg){value=4:index} : (!transfer.integer) -> !transfer.integer
  %bot2 = "transfer.constant"(%bot_arg){value=6:index} : (!transfer.integer) -> !transfer.integer
  %bot3 = "transfer.constant"(%bot_arg){value=8:index} : (!transfer.integer) -> !transfer.integer
  %bot4 = "transfer.constant"(%bot_arg){value=12:index} : (!transfer.integer) -> !transfer.integer
  %bot5 = "transfer.constant"(%bot_arg){value=14:index} : (!transfer.integer) -> !transfer.integer

  %lhs0 = "transfer.get"(%lhs) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs0 = "transfer.get"(%rhs) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top0 = "transfer.get"(%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs0_eq_rhs0 = "transfer.cmp"(%lhs0, %rhs0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs0_eq_top0 = "transfer.cmp"(%lhs0, %top0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs0_eq_top0 = "transfer.cmp"(%rhs0, %top0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res01 = "transfer.select"(%rhs0_eq_top0, %lhs0, %bot0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res02 = "transfer.select"(%lhs0_eq_top0, %rhs0, %res01) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res0 = "transfer.select"(%lhs0_eq_rhs0, %lhs0, %res02) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %lhs1 = "transfer.get"(%lhs) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs1 = "transfer.get"(%rhs) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top1 = "transfer.get"(%top) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs1_eq_rhs1 = "transfer.cmp"(%lhs1, %rhs1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs1_eq_top1 = "transfer.cmp"(%lhs1, %top1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs1_eq_top1 = "transfer.cmp"(%rhs1, %top1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res11 = "transfer.select"(%rhs1_eq_top1, %lhs1, %bot1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res12 = "transfer.select"(%lhs1_eq_top1, %rhs1, %res11) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res1 = "transfer.select"(%lhs1_eq_rhs1, %lhs1, %res12) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %lhs2 = "transfer.get"(%lhs) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs2 = "transfer.get"(%rhs) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top2 = "transfer.get"(%top) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs2_eq_rhs2 = "transfer.cmp"(%lhs2, %rhs2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs2_eq_top2 = "transfer.cmp"(%lhs2, %top2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs2_eq_top2 = "transfer.cmp"(%rhs2, %top2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res21 = "transfer.select"(%rhs2_eq_top2, %lhs2, %bot2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res22 = "transfer.select"(%lhs2_eq_top2, %rhs2, %res21) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res2 = "transfer.select"(%lhs2_eq_rhs2, %lhs2, %res22) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %lhs3 = "transfer.get"(%lhs) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs3 = "transfer.get"(%rhs) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top3 = "transfer.get"(%top) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs3_eq_rhs3 = "transfer.cmp"(%lhs3, %rhs3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs3_eq_top3 = "transfer.cmp"(%lhs3, %top3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs3_eq_top3 = "transfer.cmp"(%rhs3, %top3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res31 = "transfer.select"(%rhs3_eq_top3, %lhs3, %bot3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res32 = "transfer.select"(%lhs3_eq_top3, %rhs3, %res31) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res3 = "transfer.select"(%lhs3_eq_rhs3, %lhs3, %res32) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %lhs4 = "transfer.get"(%lhs) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs4 = "transfer.get"(%rhs) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top4 = "transfer.get"(%top) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs4_eq_rhs4 = "transfer.cmp"(%lhs4, %rhs4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs4_eq_top4 = "transfer.cmp"(%lhs4, %top4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs4_eq_top4 = "transfer.cmp"(%rhs4, %top4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res41 = "transfer.select"(%rhs4_eq_top4, %lhs4, %bot4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res42 = "transfer.select"(%lhs4_eq_top4, %rhs4, %res41) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res4 = "transfer.select"(%lhs4_eq_rhs4, %lhs4, %res42) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %lhs5 = "transfer.get"(%lhs) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %rhs5 = "transfer.get"(%rhs) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %top5 = "transfer.get"(%top) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
  %lhs5_eq_rhs5 = "transfer.cmp"(%lhs5, %rhs5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %lhs5_eq_top5 = "transfer.cmp"(%lhs5, %top5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %rhs5_eq_top5 = "transfer.cmp"(%rhs5, %top5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
  %res51 = "transfer.select"(%rhs5_eq_top5, %lhs5, %bot5) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res52 = "transfer.select"(%lhs5_eq_top5, %rhs5, %res51) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
  %res5 = "transfer.select"(%lhs5_eq_rhs5, %lhs5, %res52) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

  %result = "transfer.make"(%res0,%res1,%res2,%res3,%res4,%res5) : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>
  "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, sym_name = "meet"} : () -> ()
