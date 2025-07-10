from xdsl_smt.eval_engine.eval import AbstractDomain


def gen_table(
    bw_8_res: dict[
        tuple[AbstractDomain, str], tuple[int, int, int, int | None, int | None]
    ],
    bw_64_res: dict[
        tuple[AbstractDomain, str], tuple[int, float, float, float | None, float | None]
    ],
) -> str:
    """Generate a LaTeX table with 8-bit and 64-bit evaluation results."""

    # Start building the LaTeX table
    latex: list[str] = []

    # Table header
    latex.append("\\begin{tabular}{|l|c|c|c|c|c|c|c|c|c|c|}")
    latex.append("\\hline")
    latex.append(
        "KnownBits & \\multicolumn{5}{c|}{8-bit exact\\%} & \\multicolumn{5}{c|}{64-bit precision} \\\\"
    )
    latex.append("\\hline")
    latex.append(
        "Concrete Op & tests & $\\top$ & synth & llvm & meet & tests & $\\top$ & synth & llvm & meet \\\\"
    )
    latex.append("\\hline")

    # Get all unique operation names and sort them
    ops: set[str] = set()
    for _, op in bw_8_res.keys():
        ops.add(op)
    for _, op in bw_64_res.keys():
        ops.add(op)

    sorted_ops = sorted(ops)

    # Generate rows for each operation
    for op in sorted_ops:
        # Find matching entries for this operation
        bw_8_entry = None
        bw_64_entry = None

        for (_, op_name), data in bw_8_res.items():
            if op_name == op:
                bw_8_entry = data
                break

        for (_, op_name), data in bw_64_res.items():
            if op_name == op:
                bw_64_entry = data
                break

        if bw_8_entry is None or bw_64_entry is None:
            continue

        # Extract 8-bit data: (cases, top_exacts, synth_exacts, llvm_exacts, meet_exacts)
        cases_8, top_exacts_8, synth_exacts_8, llvm_exacts_8, meet_exacts_8 = bw_8_entry

        # Calculate percentages for 8-bit exact results
        top_pct_8 = (top_exacts_8 / cases_8) * 100 if cases_8 > 0 else 0
        synth_pct_8 = (synth_exacts_8 / cases_8) * 100 if cases_8 > 0 else 0
        llvm_pct_8 = (
            (llvm_exacts_8 / cases_8) * 100
            if cases_8 > 0 and llvm_exacts_8 is not None
            else None
        )
        meet_pct_8 = (
            (meet_exacts_8 / cases_8) * 100
            if cases_8 > 0 and meet_exacts_8 is not None
            else None
        )

        # Extract 64-bit data: (cases, top_dist, synth_dist, llvm_dist, meet_dist)
        cases_64, top_dist_64, synth_dist_64, llvm_dist_64, meet_dist_64 = bw_64_entry

        # Format the row
        llvm_pct_str = f"{llvm_pct_8:.2f}\\%" if llvm_pct_8 is not None else "N/A"
        meet_pct_str = f"{meet_pct_8:.2f}\\%" if meet_pct_8 is not None else "N/A"
        llvm_dist_str = f"{llvm_dist_64:.2f}" if llvm_dist_64 is not None else "N/A"
        meet_dist_str = f"{meet_dist_64:.2f}" if meet_dist_64 is not None else "N/A"

        row = f"{op} & {cases_8} & {top_pct_8:.2f}\\% & {synth_pct_8:.2f}\\% & {llvm_pct_str} & {meet_pct_str} & {cases_64} & {top_dist_64:.2f} & {synth_dist_64:.2f} & {llvm_dist_str} & {meet_dist_str} \\\\"
        latex.append(row)
        latex.append("\\hline")

    # Close the table
    latex.append("\\end{tabular}")

    return "\n".join(latex)
