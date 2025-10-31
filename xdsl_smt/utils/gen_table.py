from dataclasses import dataclass
from xdsl_smt.eval_engine.eval import AbstractDomain


@dataclass
class CodeData:
    num_xfer: int
    num_cond_xfer: int
    total_instructions: int


def gen_table(
    results: dict[
        tuple[AbstractDomain, str],
        tuple[
            tuple[int, int, int, int | None, int | None],  # 8-bit data
            tuple[int, float, float, float | None, float | None],  # 64-bit data
            CodeData,
        ],
    ],
) -> str:
    """Generate a LaTeX table with 8-bit and 64-bit evaluation results."""

    # Start building the LaTeX table
    latex: list[str] = []

    # Table header
    latex.append("\\begin{tabular}{@{}|l")
    latex.append("                rrr")
    latex.append("                |r")
    latex.append("                rrrr")
    latex.append("                |r")
    latex.append("                rrrr@{}}")
    latex.append("\\toprule")
    latex.append(
        "\\multirow{2}{*}{\\textbf{ConcreteOp}} & \\multicolumn{3}{c}{} & \\multirow{2}{*}{\\textbf{Tests}} & \\multicolumn{4}{c}{\\textbf{8-bit exact (\\%)} $\\uparrow$} & \\multirow{2}{*}{\\textbf{Tests}} & \\multicolumn{4}{c}{\\textbf{64-bit precision (norm) $\\downarrow$}} \\\\"
    )
    latex.append("\\cmidrule(lr){2-4} \\cmidrule(lr){6-9} \\cmidrule(lr){11-14}")
    latex.append(
        " & \\#$\\tf$ & \\#$c$ & \\#inst & & $\\top$ & synth & llvm & meet & & $\\top$ & synth & llvm & meet \\\\"
    )
    latex.append("\\midrule")

    # Sort keys by operation name for consistent ordering
    sorted_keys = sorted(results.keys(), key=lambda x: x[1])

    # Generate rows for each operation
    for domain, op in sorted_keys:
        bw_8_entry, bw_64_entry, code_data = results[(domain, op)]

        # Add asterisk for SConstRange domain
        op_display = f"{op}*" if domain == AbstractDomain.SConstRange else op

        # Extract 8-bit data: (cases, top_exacts, synth_exacts, llvm_exacts, meet_exacts)
        cases_8, top_exacts_8, synth_exacts_8, llvm_exacts_8, meet_exacts_8 = bw_8_entry

        # Extract 64-bit data: (cases, top_dist, synth_dist, llvm_dist, meet_dist)
        cases_64, top_dist_64, synth_dist_64, llvm_dist_64, meet_dist_64 = bw_64_entry

        if llvm_exacts_8 is None:
            meet_exacts_8 = synth_exacts_8
        if llvm_dist_64 is None:
            meet_dist_64 = synth_dist_64

        # Calculate percentages for 8-bit exact results
        top_pct_8 = (top_exacts_8 / cases_8) * 100
        synth_pct_8 = (synth_exacts_8 / cases_8) * 100
        llvm_pct_8 = (
            (llvm_exacts_8 / cases_8) * 100 if llvm_exacts_8 is not None else None
        )
        meet_pct_8 = (
            (meet_exacts_8 / cases_8) * 100 if meet_exacts_8 is not None else None
        )

        # Format 8-bit data
        llvm_pct_str = f"{llvm_pct_8:.2f}" if llvm_pct_8 is not None else "N/A"
        meet_pct_str = f"{meet_pct_8:.2f}" if meet_pct_8 is not None else "N/A"

        # Bold meet values if they are better than llvm or if llvm is None
        if meet_exacts_8 is not None and (
            llvm_exacts_8 is None or meet_exacts_8 > llvm_exacts_8
        ):
            meet_pct_str = f"\\textbf{{{meet_pct_8:.2f}}}"

        # Handle 64-bit data based on cases_64
        if cases_64 == 0:
            dist_part = "- & - & - & -"
        else:
            top_dist_norm = top_dist_64 / cases_64
            synth_dist_norm = synth_dist_64 / cases_64
            llvm_dist_norm = None if llvm_dist_64 is None else llvm_dist_64 / cases_64
            meet_dist_norm = None if meet_dist_64 is None else meet_dist_64 / cases_64
            llvm_dist_str = (
                f"{llvm_dist_norm:.3f}" if llvm_dist_norm is not None else "N/A"
            )
            meet_dist_str = (
                f"{meet_dist_norm:.3f}" if meet_dist_norm is not None else "N/A"
            )

            # Bold meet distance if it's better than llvm or if llvm is None
            if meet_dist_64 is not None and (
                llvm_dist_64 is None or meet_dist_64 < llvm_dist_64
            ):
                meet_dist_str = f"\\textbf{{{meet_dist_norm:.3f}}}"

            dist_part = f"{top_dist_norm:.3f} & {synth_dist_norm:.3f} & {llvm_dist_str} & {meet_dist_str}"

        row = f"{op_display} & {code_data.num_xfer} & {code_data.num_cond_xfer} & {code_data.total_instructions} & {cases_8} & {top_pct_8:.2f} & {synth_pct_8:.2f} & {llvm_pct_str} & {meet_pct_str} & {cases_64} & {dist_part} \\\\"
        latex.append(row)

    # Close the table
    latex.append("\\bottomrule")
    latex.append("\\end{tabular}")

    return "\n".join(latex)
