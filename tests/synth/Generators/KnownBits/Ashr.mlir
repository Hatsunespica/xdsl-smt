"builtin.module"() ({
"func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    "func.return"(%arg0) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()
  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "input_generator_0"} : () -> ()

"func.func"() ({
  ^bb0(%arg0: !transfer.abs_value<[!transfer.integer,!transfer.integer]>, %arg1: !transfer.abs_value<[!transfer.integer,!transfer.integer]>):
    %r0 = "transfer.get"(%arg1) {index = 0 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %r1 = "transfer.get"(%arg1) {index = 1 : index} : (!transfer.abs_value<[!transfer.integer, !transfer.integer]>) -> !transfer.integer
    %one = "transfer.constant"(%r0) {value = 1 : index} : (!transfer.integer) -> !transfer.integer
    %bw = "transfer.get_bit_width"(%r0) : (!transfer.integer) -> !transfer.integer
    %tmp_log2_bw = "transfer.countl_zero"(%bw) : (!transfer.integer) -> !transfer.integer
    %log2_bw = "transfer.sub"(%bw, %tmp_log2_bw) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %one_shift_log2_bw = "transfer.shl"(%one, %log2_bw) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %mask = "transfer.sub"(%one_shift_log2_bw, %one) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %new_r1 = "transfer.and"(%r1, %mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %all_ones = "transfer.constant"(%r0) {value = -1 : index} : (!transfer.integer) -> !transfer.integer
    %neg_mask = "transfer.xor"(%mask, %all_ones) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %new_r0 = "transfer.or"(%r0, %neg_mask) : (!transfer.integer, !transfer.integer) -> !transfer.integer
    %new_abs = "transfer.make"(%new_r0, %new_r1) : (!transfer.integer, !transfer.integer) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>
    "func.return"(%new_abs) : (!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> ()


  }) {function_type = (!transfer.abs_value<[!transfer.integer,!transfer.integer]>,!transfer.abs_value<[!transfer.integer,!transfer.integer]>) -> !transfer.abs_value<[!transfer.integer,!transfer.integer]>, sym_name = "input_generator_1"} : () -> ()

}): () -> ()
