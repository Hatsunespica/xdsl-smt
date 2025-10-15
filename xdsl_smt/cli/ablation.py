from argparse import ArgumentParser, Namespace, ArgumentDefaultsHelpFormatter
from pathlib import Path
import pickle
from typing import Dict, Tuple, List

from xdsl_smt.eval_engine.eval import AbstractDomain
from xdsl_smt.utils.gen_table import CodeData


def register_all_arguments() -> Namespace:
    ap = ArgumentParser(prog="ablation", formatter_class=ArgumentDefaultsHelpFormatter)

    ap.add_argument(
        "pickle_files",
        nargs="+",
        type=Path,
        help="Path(s) to pickle files containing evaluation results",
    )
    ap.add_argument(
        "-latex_table",
        action="store_true",
        help="Generate and print a latex table from the combined results",
    )

    return ap.parse_args()


# Type alias for the results structure
ResultsDict = Dict[
    Tuple[AbstractDomain, str],
    Tuple[
        Tuple[int, int, int, int | None, int | None],
        Tuple[int, float, float, float | None, float | None],
        CodeData,
    ],
]


def load_pickle_file(pickle_path: Path) -> ResultsDict:
    """Load results from a pickle file."""
    try:
        with open(pickle_path, "rb") as f:
            results = pickle.load(f)
        print(f"Successfully loaded {len(results)} entries from {pickle_path}")
        return results
    except Exception as e:
        print(f"Error loading {pickle_path}: {e}")
        return {}


def main() -> None:
    args = register_all_arguments()

    # Validate input files
    valid_files: List[Path] = []
    for pickle_path in args.pickle_files:
        if not pickle_path.exists():
            print(f"Warning: File {pickle_path} does not exist, skipping")
            continue
        if not pickle_path.suffix == ".pkl":
            print(
                f"Warning: File {pickle_path} does not have .pkl extension, trying anyway"
            )
        valid_files.append(pickle_path)

    # Load all pickle files
    all_results: List[ResultsDict] = []
    for pickle_path in valid_files:
        results = load_pickle_file(pickle_path)
        if results:
            all_results.append(results)

    # Create table mapping each key to a tuple whose length = number of pkl files
    table: Dict[Tuple[AbstractDomain, str], Tuple[float, ...]] = {}

    # Only consider keys that appear in ALL pickle files
    if not all_results:
        print("No valid pickle files loaded")
        return

    # Find keys that appear in all result files
    common_keys = set(all_results[0].keys())
    for result in all_results[1:]:
        common_keys = common_keys.intersection(set(result.keys()))
    # sort common keys by operation name
    common_keys = sorted(common_keys, key=lambda item: item[1])

    print(
        f"Found {len(common_keys)} keys that appear in all {len(all_results)} pickle files"
    )

    # For each key that appears in all pickle files, create a tuple with values from each pickle file
    for key in common_keys:
        values: List[float] = []
        for result in all_results:
            # Since we're only using common_keys, this key should exist in all results
            assert key in result, f"Key {key} should exist in all results"
            all_8, _, synth_8, _, _ = result[key][0]
            value = synth_8 / all_8 if all_8 != 0 else 0.0
            values.append(value)
        table[key] = tuple(values)

    # Print the table structure
    print(
        f"\nTable contains {len(table)} keys, each mapped to tuples of length {len(all_results)}"
    )
    print(f"Number of pickle files processed: {len(all_results)}")

    # Print a sample of the table
    print("\nSample entries:")
    for key, value_tuple in table.items():
        print(f"  {key}: {value_tuple}")

    if args.latex_table:
        latex = gen_latex_table(table, len(all_results))
        print("\nGenerated LaTeX Table:\n")
        print(latex)


def gen_latex_table(
    table: Dict[Tuple[AbstractDomain, str], Tuple[float, ...]], num_files: int
) -> str:
    """Generate a LaTeX table from the ablation results."""
    # Get all function names and their corresponding keys
    table_items = list(table.items())
    functions = [func for (_, func), _ in table_items]

    # Split functions into 2 groups instead of 3
    num_funcs = len(functions)
    funcs_per_group = (num_funcs + 1) // 2  # Split into 2 groups

    tables: List[str] = []
    for group_idx in range(2):
        start_idx = group_idx * funcs_per_group
        end_idx = min(start_idx + funcs_per_group, num_funcs)

        if start_idx >= num_funcs:
            break

        group_functions = functions[start_idx:end_idx]
        group_table_items = table_items[start_idx:end_idx]

        # Pad with empty columns if needed to reach 20, or adjust column spec
        col_spec = f"@{{}}C{{\\fw}}*{{{funcs_per_group}}}{{C{{\\cw}}}}@{{}}"

        # Create header with bench commands for this group
        bench_headers = [f"\\bench{{{func}}}" for func in group_functions]
        # If this is the second group and we have fewer than expected, pad with empty
        if group_idx == 1 and len(bench_headers) < funcs_per_group:
            bench_headers.append("{}")  # Add empty column as in your example

        header = " &\n" + " & ".join(bench_headers) + " \\\\\n"

        # Create rows for each file
        rows: List[str] = []

        # First, get the baseline values from File 1
        baseline_values: List[float] = []
        for (_, _), values in group_table_items:
            baseline_values.append(values[0] * 100)  # Convert to percentage

        for file_idx in range(num_files):
            row_values: List[str] = []
            for i, ((_, _), values) in enumerate(group_table_items):
                assert file_idx < len(values)
                percentage = values[file_idx] * 100

                if file_idx == 0:
                    # First file: show original percentage
                    row_values.append(f"{percentage:.1f}")
                else:
                    # Files 2+: show difference from first file
                    diff = percentage - baseline_values[i]
                    if diff > 0:
                        row_values.append(f"+{diff:.1f}")
                    else:
                        row_values.append(
                            f"{diff:.1f}"
                        )  # Negative sign is already included

            # If this is the second group and we padded the header, pad the row too
            if group_idx == 1 and len(group_functions) < funcs_per_group:
                row_values.append("{}")

            row = f"File {file_idx+1} & " + " & ".join(row_values) + " \\\\"
            rows.append(row)

        body = "\n".join(rows)

        # Create table with proper formatting
        group_table = f"\\begin{{tabular}}{{{col_spec}}}\n\\toprule\n{header}\\midrule\n{body}\n\\bottomrule\n\\end{{tabular}}"
        tables.append(group_table)

    # Combine tables with vspace
    return "\n\n\\vspace{-1pt}\n\n% ===== Row 2 =====\n".join(tables)


if __name__ == "__main__":
    main()
