"builtin.module"() ({

 "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %arg0_0 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg0_1 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg1_0 = "transfer.get"(%arg1) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg1_1 = "transfer.get"(%arg1) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %and_zeros = "transfer.and"(%arg0_0, %arg1_0) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %and_ones = "transfer.and"(%arg0_1, %arg1_1) : (!transfer.integer,!transfer.integer) -> !transfer.integer
    %result="transfer.make"(%and_zeros,%and_ones):(!transfer.integer,!transfer.integer)->!transfer.abs_value<[!transfer.integer,!transfer.integer]>
    "func.return"(%result) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>, !transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "join"} : () -> ()

   "func.func"() ({
  ^bb0(%arg0: !transfer.integer):
    %neg_arg0 = "transfer.neg"(%arg0) : (!transfer.integer) -> !transfer.integer
    %result="transfer.make"(%neg_arg0,%arg0):(!transfer.integer,!transfer.integer)->!transfer.abs_value<[!transfer.integer,!transfer.integer]>
    "func.return"(%result) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.integer) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "fromConstant"} : () -> ()

"func.func"() ({
  ^bb0(%arg0: !transfer.integer, %arg1: !transfer.integer):
    // (N2.isZero() || (N1.isMinSignedValue() && N2.isAllOnes()))
    %const0 = "transfer.constant"(%arg1) {value=0:index}:(!transfer.integer)->!transfer.integer
    %arg1_neq_0 = "transfer.cmp"(%const0, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg0_eq_0 = "transfer.cmp"(%const0, %arg0) {predicate=0:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg0_plus_arg0 = "transfer.add"(%arg0, %arg0) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %arg0_plus_arg0_neq_0 = "transfer.cmp"(%arg0_plus_arg0, %const0) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
    %arg0_neq_smin = "arith.ori"(%arg0_eq_0, %arg0_plus_arg0_neq_0) : (i1, i1) -> i1
    %minus1 = "transfer.get_all_ones"(%arg0) : (!transfer.integer) -> !transfer.integer
    %arg1_neq_minus1 = "transfer.cmp"(%minus1, %arg1) {predicate=1:i64}: (!transfer.integer, !transfer.integer) -> i1
    %not_ub2 = "arith.ori"(%arg0_neq_smin, %arg1_neq_minus1) : (i1, i1) -> i1
    %not_ub = "arith.andi"(%arg1_neq_0, %not_ub2) : (i1, i1) -> i1
    "func.return"(%not_ub) : (i1) -> ()
  }) {function_type = (!transfer.integer, !transfer.integer) -> i1, sym_name = "op_constraint"} : () -> ()

"func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %const0 = "transfer.constant"(%arg00){value=0:index} : (!transfer.integer) -> !transfer.integer
    %const1 = "transfer.constant"(%arg00){value=1:index} : (!transfer.integer) -> !transfer.integer
    %constMax = "transfer.sub"(%const0, %const1) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %result = "transfer.make"(%const0, %constMax) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "getTop"} : () -> ()


   "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg10 = "transfer.get"(%arg1) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg11 = "transfer.get"(%arg1) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %min0 = "transfer.umin"(%arg00,%arg10): (!transfer.integer,!transfer.integer)->!transfer.integer
    %max0 = "transfer.umax"(%arg01,%arg11): (!transfer.integer,!transfer.integer)->!transfer.integer
    %result = "transfer.make"(%min0, %max1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer, !transfer.integer]>
    "func.return"(%result) : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>, !transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "meet"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %result = "transfer.cmp"(%arg00, %arg01){predicate=7:i64}:(!transfer.integer,!transfer.integer)->i1
    "func.return"(%result) : (i1) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> i1, sym_name = "getConstraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %inst: !transfer.integer):
    %arg00 = "transfer.get"(%arg0) {index=0:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %arg01 = "transfer.get"(%arg0) {index=1:index}: (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.integer
    %cmp1 = "transfer.cmp"(%arg00, %inst){predicate=7:i64}:(!transfer.integer,!transfer.integer)->i1
    %cmp2="transfer.cmp"(%inst,%arg01){predicate=7:i64}:(!transfer.integer,!transfer.integer)->i1
    %result="arith.andi"(%cmp1,%cmp2):(i1,i1)->i1
    "func.return"(%result) : (i1) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>, !transfer.integer) -> i1, sym_name = "getInstanceConstraint"} : () -> ()

  "func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "DIVSImpl", applied_to=["comb.divs"], CPPCLASS=["circt::comb::DIVSOp"], is_forward=true} : () -> ()

}) : () -> ()
