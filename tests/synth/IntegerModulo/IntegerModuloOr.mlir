// TODO this really only works if bw >= 4, and needs to be fixed to work on lower bws
// TODO pull some of the duplicated code out into functions
// TODO fix copied funcs
"builtin.module"() ({

"func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %c2 = "transfer.constant"(%arg00){value=2:index} : (!transfer.integer) -> !transfer.integer
    %c3 = "transfer.constant"(%arg00){value=3:index} : (!transfer.integer) -> !transfer.integer
    %c5 = "transfer.constant"(%arg00){value=5:index} : (!transfer.integer) -> !transfer.integer
    %c7 = "transfer.constant"(%arg00){value=7:index} : (!transfer.integer) -> !transfer.integer
    %c11 = "transfer.constant"(%arg00){value=11:index} : (!transfer.integer) -> !transfer.integer
    %c13 = "transfer.constant"(%arg00){value=13:index} : (!transfer.integer) -> !transfer.integer
    %top = "transfer.make"(%c2, %c3, %c5, %c7, %c11, %c13) :
      (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer)
      -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>
    "func.return"(%top) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>)
        -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>,
    sym_name = "getTop"} : () -> ()

"func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
    %bot_arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %b3 = "transfer.constant"(%bot_arg00){value=3:index} : (!transfer.integer) -> !transfer.integer
    %b4 = "transfer.constant"(%bot_arg00){value=4:index} : (!transfer.integer) -> !transfer.integer
    %b6 = "transfer.constant"(%bot_arg00){value=6:index} : (!transfer.integer) -> !transfer.integer
    %b8 = "transfer.constant"(%bot_arg00){value=8:index} : (!transfer.integer) -> !transfer.integer
    %b12 = "transfer.constant"(%bot_arg00){value=12:index} : (!transfer.integer) -> !transfer.integer
    %b14 = "transfer.constant"(%bot_arg00){value=14:index} : (!transfer.integer) -> !transfer.integer
    %bot = "transfer.make"(%b3, %b4, %b6, %b8, %b12, %b14) :
      (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer)
      -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>
    "func.return"(%bot) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
}) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>)
        -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>,
    sym_name = "getBottom"} : () -> ()

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

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>,!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, sym_name = "ORImpl", applied_to=["comb.or"], CPPCLASS=["circt::comb::OrOp"], is_forward=true} : () -> ()

  "func.func"() ({
  ^bb0(%lhs0: !transfer.integer, %rhs0: !transfer.integer, %top0: !transfer.integer, %bot0: !transfer.integer):
    %lhs0_eq_rhs0 = "transfer.cmp"(%lhs0, %rhs0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs0_eq_top0 = "transfer.cmp"(%lhs0, %top0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs0_eq_top0 = "transfer.cmp"(%rhs0, %top0) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res01 = "transfer.select"(%rhs0_eq_top0, %lhs0, %bot0) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res02 = "transfer.select"(%lhs0_eq_top0, %rhs0, %res01) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res00 = "transfer.select"(%lhs0_eq_rhs0, %lhs0, %res02) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res00) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet0"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs1: !transfer.integer, %rhs1: !transfer.integer, %top1: !transfer.integer, %bot1: !transfer.integer):
    %lhs1_eq_rhs1 = "transfer.cmp"(%lhs1, %rhs1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs1_eq_top1 = "transfer.cmp"(%lhs1, %top1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs1_eq_top1 = "transfer.cmp"(%rhs1, %top1) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res11 = "transfer.select"(%rhs1_eq_top1, %lhs1, %bot1) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res12 = "transfer.select"(%lhs1_eq_top1, %rhs1, %res11) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res10 = "transfer.select"(%lhs1_eq_rhs1, %lhs1, %res12) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res10) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet1"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs2: !transfer.integer, %rhs2: !transfer.integer, %top2: !transfer.integer, %bot2: !transfer.integer):
    %lhs2_eq_rhs2 = "transfer.cmp"(%lhs2, %rhs2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs2_eq_top2 = "transfer.cmp"(%lhs2, %top2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs2_eq_top2 = "transfer.cmp"(%rhs2, %top2) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res21 = "transfer.select"(%rhs2_eq_top2, %lhs2, %bot2) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res22 = "transfer.select"(%lhs2_eq_top2, %rhs2, %res21) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res20 = "transfer.select"(%lhs2_eq_rhs2, %lhs2, %res22) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res20) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet2"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs3: !transfer.integer, %rhs3: !transfer.integer, %top3: !transfer.integer, %bot3: !transfer.integer):
    %lhs3_eq_rhs3 = "transfer.cmp"(%lhs3, %rhs3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs3_eq_top3 = "transfer.cmp"(%lhs3, %top3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs3_eq_top3 = "transfer.cmp"(%rhs3, %top3) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res31 = "transfer.select"(%rhs3_eq_top3, %lhs3, %bot3) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res32 = "transfer.select"(%lhs3_eq_top3, %rhs3, %res31) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res30 = "transfer.select"(%lhs3_eq_rhs3, %lhs3, %res32) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res30) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet3"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs4: !transfer.integer, %rhs4: !transfer.integer, %top4: !transfer.integer, %bot4: !transfer.integer):
    %lhs4_eq_rhs4 = "transfer.cmp"(%lhs4, %rhs4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs4_eq_top4 = "transfer.cmp"(%lhs4, %top4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs4_eq_top4 = "transfer.cmp"(%rhs4, %top4) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res41 = "transfer.select"(%rhs4_eq_top4, %lhs4, %bot4) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res42 = "transfer.select"(%lhs4_eq_top4, %rhs4, %res41) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res40 = "transfer.select"(%lhs4_eq_rhs4, %lhs4, %res42) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res40) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet4"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs5: !transfer.integer, %rhs5: !transfer.integer, %top5: !transfer.integer, %bot5: !transfer.integer):
    %lhs5_eq_rhs5 = "transfer.cmp"(%lhs5, %rhs5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %lhs5_eq_top5 = "transfer.cmp"(%lhs5, %top5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1
    %rhs5_eq_top5 = "transfer.cmp"(%rhs5, %top5) {predicate = 0} : (!transfer.integer, !transfer.integer) -> i1

    %res51 = "transfer.select"(%rhs5_eq_top5, %lhs5, %bot5) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res52 = "transfer.select"(%lhs5_eq_top5, %rhs5, %res51) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer
    %res50 = "transfer.select"(%lhs5_eq_rhs5, %lhs5, %res52) : (i1, !transfer.integer, !transfer.integer) -> !transfer.integer

    "func.return"(%res50) : (!transfer.integer) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer, sym_name = "meet5"} : () -> ()

  "func.func"() ({
  ^bb0(%lhs: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, %rhs: !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>):
    %top = "func.call"(%lhs) {callee = @getTop} : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>
    %bot = "func.call"(%lhs) {callee = @getBottom} : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>

    %lhs0 = "transfer.get"(%lhs) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs0 = "transfer.get"(%rhs) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top0 = "transfer.get"(%top) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot0 = "transfer.get"(%bot) {index=0:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res0 = "func.call"(%lhs0, %rhs0, %top0, %bot0) {callee = @meet0} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs1 = "transfer.get"(%lhs) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs1 = "transfer.get"(%rhs) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top1 = "transfer.get"(%top) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot1 = "transfer.get"(%bot) {index=1:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res1 = "func.call"(%lhs1, %rhs1, %top1, %bot1) {callee = @meet1} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs2 = "transfer.get"(%lhs) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs2 = "transfer.get"(%rhs) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top2 = "transfer.get"(%top) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot2 = "transfer.get"(%bot) {index=2:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res2 = "func.call"(%lhs2, %rhs2, %top2, %bot2) {callee = @meet2} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs3 = "transfer.get"(%lhs) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs3 = "transfer.get"(%rhs) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top3 = "transfer.get"(%top) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot3 = "transfer.get"(%bot) {index=3:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res3 = "func.call"(%lhs3, %rhs3, %top3, %bot3) {callee = @meet3} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs4 = "transfer.get"(%lhs) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs4 = "transfer.get"(%rhs) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top4 = "transfer.get"(%top) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot4 = "transfer.get"(%bot) {index=4:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res4 = "func.call"(%lhs4, %rhs4, %top4, %bot4) {callee = @meet4} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %lhs5 = "transfer.get"(%lhs) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %rhs5 = "transfer.get"(%rhs) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %top5 = "transfer.get"(%top) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %bot5 = "transfer.get"(%bot) {index=5:index}: (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.integer
    %res5 = "func.call"(%lhs5, %rhs5, %top5, %bot5) {callee = @meet5} : (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer) -> !transfer.integer

    %result = "transfer.make"(%res0,%res1,%res2,%res3,%res4,%res5) :
      (!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer)
      -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>

     "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>) -> !transfer.abs_value<[!transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer, !transfer.integer]>, sym_name = "meet"} : () -> ()

}): () -> ()
