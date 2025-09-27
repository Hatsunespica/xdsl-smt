#!/usr/bin/env python3
# pyright: ignore-file
"""
Program to process directories and run specified executables on C++ files.

For each subfolder 'a' in the input directory:
- If a_conc.cpp exists, feed it to ./xdsl_smt/eval_engine/build/xfer_enum
- If a_abs.cpp exists, feed it to ./xdsl_smt/eval_engine/build/eval_engine
- Skip subfolders that don't have the required files
"""

import sys
import subprocess
import argparse
import shutil
from pathlib import Path

from xdsl_smt.eval_engine.eval import _parse_engine_output
from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult


def run_executable_with_header(
    executable,
    cpp_file,
    subfolder_path,
    header_parts,
    abstract_domain,
    create_dir=False,
):
    """Run an executable with a formatted header and C++ code."""
    try:
        # Create the input with required header
        enum_result_dir = str(subfolder_path) + "/enum_data/"

        # Create directory if needed
        if create_dir:
            enum_dir_path = Path(enum_result_dir)
            if enum_dir_path.exists():
                shutil.rmtree(enum_dir_path)
            enum_dir_path.mkdir(parents=True, exist_ok=True)

        # Build header with common parts and specific parts
        header_lines = [enum_result_dir, abstract_domain] + header_parts
        header = "\n".join(header_lines) + "\n\n"

        # Read the C++ code
        with open(cpp_file, "r") as f:
            cpp_content = f.read()

        # Combine header and C++ code
        full_input = header + cpp_content

        # print(f"Running: {executable} with formatted input from {cpp_file}")
        result = subprocess.run(
            [executable],
            input=full_input,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=30,  # 30 second timeout
        )

        if result.returncode == 0:
            # print(f"✓ Success: {executable} processed {cpp_file}")
            return result.stdout
        else:
            # print(f"✗ Error: {executable} failed on {cpp_file}")
            if result.stderr.strip():
                print(f"  Error: {result.stderr.strip()}")
            return None

    except subprocess.TimeoutExpired:
        print(f"✗ Timeout: {executable} timed out on {cpp_file}")
        return None
    except FileNotFoundError:
        print(f"✗ Error: Executable {executable} not found")
        return None
    except Exception as e:
        print(f"✗ Error: {e}")
        return None


def run_xfer_enum(executable, cpp_file, script_dir, subfolder_path, abstract_domain):
    """Run xfer_enum with the proper header format and C++ code."""
    EvalResult.init_bw_settings({4}, {8}, {64})
    bitwidth_configs = "[4]\n[(8, 1000)]\n[(64, 1000, 100)]"
    random_seed = "123777"
    header_parts = [bitwidth_configs, random_seed]
    _ = run_executable_with_header(
        executable,
        cpp_file,
        subfolder_path,
        header_parts,
        abstract_domain,
        create_dir=True,
    )


def run_eval_engine(executable, cpp_file, script_dir, subfolder_path, abstract_domain):
    """Run eval_engine with the proper header format and C++ code."""
    empty_list = "[]"
    amurth_tf_list = "['amurth_tf']"
    header_parts = ["", amurth_tf_list, empty_list]
    engine_output = run_executable_with_header(
        executable,
        cpp_file,
        subfolder_path,
        header_parts,
        abstract_domain,
        create_dir=False,
    )
    if engine_output:
        result = _parse_engine_output(engine_output)[0]
        print(result)
        is_sound = result.is_sound()
        exact_prop = result.get_exact_prop()
        return is_sound, exact_prop
    return None, None


def process_single_benchmark(
    benchmark_path, xfer_enum, eval_engine, script_dir, abstract_domain
):
    """Process a single benchmark directory."""
    folder_name = benchmark_path.name
    print(f"Processing single benchmark: {folder_name}")

    # Look for the expected files (no suffix needed anymore)
    conc_file = benchmark_path / f"{folder_name}_conc.cpp"
    abs_file = benchmark_path / f"{folder_name}_abs.cpp"

    found_files = False
    is_sound = None
    exact_prop = None

    # Process _conc.cpp file with xfer_enum
    if conc_file.exists():
        found_files = True
        # print(f"  Found: {conc_file.name}")
        run_xfer_enum(
            str(xfer_enum), str(conc_file), script_dir, benchmark_path, abstract_domain
        )

    # Process _abs.cpp file with eval_engine
    if abs_file.exists():
        found_files = True
        # print(f"  Found: {abs_file.name}")
        is_sound, exact_prop = run_eval_engine(
            str(eval_engine), str(abs_file), script_dir, benchmark_path, abstract_domain
        )

    if not found_files:
        print(f"  Skipping: No {folder_name}_conc.cpp or {folder_name}_abs.cpp found")
        return False

    # Print results for single benchmark
    if is_sound is not None and exact_prop is not None:
        print(f"\nResults for {folder_name}:")
        print(f"  is_sound?: {is_sound}")
        print(f"  exact%: {exact_prop * 100:.2f}%")

    return True


def process_category_directory(
    category_path, xfer_enum, eval_engine, script_dir, abstract_domain
):
    """Process all benchmarks in a category directory (signed/unsigned)."""
    category_name = category_path.name
    print(f"Processing {category_name} operations:")

    processed_count = 0
    skipped_count = 0
    results = []  # List to store (folder_name, is_sound, exact_prop) tuples

    for subfolder in sorted(category_path.iterdir()):
        if not subfolder.is_dir():
            continue

        folder_name = subfolder.name
        print(f"  Processing subfolder: {folder_name}")

        # Look for the expected files (no suffix needed anymore)
        conc_file = subfolder / f"{folder_name}_conc.cpp"
        abs_file = subfolder / f"{folder_name}_abs.cpp"

        found_files = False
        is_sound = None
        exact_prop = None

        # Process _conc.cpp file with xfer_enum
        if conc_file.exists():
            found_files = True
            # print(f"    Found: {conc_file.name}")
            run_xfer_enum(
                str(xfer_enum), str(conc_file), script_dir, subfolder, abstract_domain
            )

        # Process _abs.cpp file with eval_engine
        if abs_file.exists():
            found_files = True
            # print(f"    Found: {abs_file.name}")
            is_sound, exact_prop = run_eval_engine(
                str(eval_engine), str(abs_file), script_dir, subfolder, abstract_domain
            )

        if found_files:
            processed_count += 1
            if is_sound is not None and exact_prop is not None:
                results.append((folder_name, is_sound, exact_prop))
        else:
            print(
                f"    Skipping: No {folder_name}_conc.cpp or {folder_name}_abs.cpp found"
            )
            skipped_count += 1

        print()

    # Print results table for multiple benchmarks
    if results:
        print(f"\nResults table for {category_name} operations:")
        print(f"{'Benchmark':<20} {'is_sound?':<10} {'exact%'}")
        print("-" * 50)
        for folder_name, is_sound, exact_prop in results:
            print(f"{folder_name:<20} {str(is_sound):<10} {exact_prop * 100:.2f}%")

    return processed_count, skipped_count


def process_directory(input_dir, abstract_domain, single_benchmark=False):
    """Process directories - either a single benchmark or a set of benchmarks."""
    input_path = Path(input_dir).resolve()

    if not input_path.exists() or not input_path.is_dir():
        print(f"Error: {input_dir} is not a valid directory")
        return False

    # Get absolute paths to executables
    script_dir = Path(
        __file__
    ).parent.parent  # Go up one level from amurth_compare to xdsl-smt
    xfer_enum = script_dir / "eval_engine" / "build" / "xfer_enum"
    eval_engine = script_dir / "eval_engine" / "build" / "eval_engine"

    # Check if executables exist
    if not xfer_enum.exists():
        print(f"Error: {xfer_enum} not found")
        return False

    if not eval_engine.exists():
        print(f"Error: {eval_engine} not found")
        return False

    print(f"Processing directory: {input_path}")
    print(f"Using abstract domain: {abstract_domain}")
    print(f"Using executables:")
    print(f"  xfer_enum: {xfer_enum}")
    print(f"  eval_engine: {eval_engine}")
    print()

    if single_benchmark:
        # Single benchmark mode
        success = process_single_benchmark(
            input_path, xfer_enum, eval_engine, script_dir, abstract_domain
        )
        print(f"Summary:")
        print(f"  Processed transformers: {1 if success else 0}")
        print(f"  Skipped transformers: {0 if success else 1}")
        return success
    else:
        # Set of benchmarks mode
        processed_count, skipped_count = process_category_directory(
            input_path, xfer_enum, eval_engine, script_dir, abstract_domain
        )
        print(f"Summary:")
        print(f"  Processed transformers: {processed_count}")
        print(f"  Skipped transformers: {skipped_count}")
        return processed_count > 0


def main():
    parser = argparse.ArgumentParser(
        description="Process directories and run executables on C++ files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Process all benchmarks in signed category
  python eval_amurth.py signed --domain SConstRange

  # Process all benchmarks in unsigned category
  python eval_amurth.py unsigned --domain UConstRange

  # Process a single benchmark
  python eval_amurth.py signed/plus --domain SConstRange --single
  python eval_amurth.py unsigned/minus --domain UConstRange --single
        """,
    )

    parser.add_argument("input_dir", help="Input directory path")

    parser.add_argument(
        "--domain",
        "-d",
        required=True,
        choices=["SConstRange", "UConstRange"],
        help="Abstract domain: SConstRange for signed, UConstRange for unsigned",
    )

    parser.add_argument(
        "--single",
        action="store_true",
        help="Process as a single benchmark directory instead of a set of benchmarks",
    )

    args = parser.parse_args()

    try:
        success = process_directory(args.input_dir, args.domain, args.single)
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
