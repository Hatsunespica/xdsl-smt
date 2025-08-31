#!/usr/bin/env python3
"""
Program to process directories and run specified executables on C++ files.

For each subfolder 'a' in the input directory:
- If a_conc.cpp exists, feed it to ./xdsl_smt/eval_engine/build/xfer_enum
- If a_abs.cpp exists, feed it to ./xdsl_smt/eval_engine/build/eval_engine
- Skip subfolders that don't have the required files
"""

import os
import sys
import subprocess
import argparse
import shutil
from pathlib import Path


def run_executable_with_header(executable, cpp_file, subfolder_path, header_parts, create_dir=False):
    """Run an executable with a formatted header and C++ code."""
    try:
        # Create the input with required header
        enum_result_dir = str(subfolder_path) + "/enum_data/"
        
        # Determine abstract domain based on folder name
        folder_name = os.path.basename(str(subfolder_path))
        if "_unsigned" in folder_name:
            abstract_domains = "UConstRange"
        elif "_signed" in folder_name:
            abstract_domains = "SConstRange"
        else:
            raise ValueError(f"Cannot determine abstract domain from folder name: {folder_name}")
        
        # Create directory if needed
        if create_dir:
            enum_dir_path = Path(enum_result_dir)
            if enum_dir_path.exists():
                shutil.rmtree(enum_dir_path)
            enum_dir_path.mkdir(parents=True, exist_ok=True)
        
        # Build header with common parts and specific parts
        header_lines = [enum_result_dir, abstract_domains] + header_parts
        header = "\n".join(header_lines) + "\n\n"
        
        # Read the C++ code
        with open(cpp_file, 'r') as f:
            cpp_content = f.read()
        
        # Combine header and C++ code
        full_input = header + cpp_content

        print(f"Running: {executable} with formatted input from {cpp_file}")
        result = subprocess.run(
            [executable],
            input=full_input,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=30  # 30 second timeout
        )
        
        if result.returncode == 0:
            print(f"✓ Success: {executable} processed {cpp_file}")
            if result.stdout.strip():
                print(f"  Output: {result.stdout.strip()}")
        else:
            print(f"✗ Error: {executable} failed on {cpp_file}")
            if result.stderr.strip():
                print(f"  Error: {result.stderr.strip()}")
        
        return result.returncode == 0
        
    except subprocess.TimeoutExpired:
        print(f"✗ Timeout: {executable} timed out on {cpp_file}")
        return False
    except FileNotFoundError:
        print(f"✗ Error: Executable {executable} not found")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False


def run_xfer_enum(executable, cpp_file, script_dir, subfolder_path):
    """Run xfer_enum with the proper header format and C++ code."""
    bitwidth_configs = "[4]\n[(8, 1000)]\n[(64, 1000, 100)]"
    random_seed = "123777"
    header_parts = [bitwidth_configs, random_seed]
    return run_executable_with_header(executable, cpp_file, subfolder_path, header_parts, create_dir=True)


def run_eval_engine(executable, cpp_file, script_dir, subfolder_path):
    """Run eval_engine with the proper header format and C++ code."""
    empty_list = "[]"
    amurth_tf_list = "['amurth_tf']"
    header_parts = ["", amurth_tf_list, empty_list]
    return run_executable_with_header(executable, cpp_file, subfolder_path, header_parts, create_dir=False)


def run_command(executable, input_file):
    """Run a command with the given input file and return the result."""
    try:
        print(f"Running: {executable} < {input_file}")
        result = subprocess.run(
            [executable],
            stdin=open(input_file, 'r'),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=30  # 30 second timeout
        )
        
        if result.returncode == 0:
            print(f"✓ Success: {executable} processed {input_file}")
            if result.stdout.strip():
                print(f"  Output: {result.stdout.strip()}")
        else:
            print(f"✗ Error: {executable} failed on {input_file}")
            if result.stderr.strip():
                print(f"  Error: {result.stderr.strip()}")
        
        return result.returncode == 0
        
    except subprocess.TimeoutExpired:
        print(f"✗ Timeout: {executable} timed out on {input_file}")
        return False
    except FileNotFoundError:
        print(f"✗ Error: Executable {executable} not found")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False


def process_directory(input_dir, benchmark=None):
    """Process all subdirectories in the input directory."""
    input_path = Path(input_dir).resolve()
    
    if not input_path.exists() or not input_path.is_dir():
        print(f"Error: {input_dir} is not a valid directory")
        return False
    
    # Get absolute paths to executables
    script_dir = Path(__file__).parent.parent  # Go up one level from amurth_compare to xdsl-smt
    xfer_enum = script_dir / "xdsl_smt" / "eval_engine" / "build" / "xfer_enum"
    eval_engine = script_dir / "xdsl_smt" / "eval_engine" / "build" / "eval_engine"
    
    # Check if executables exist
    if not xfer_enum.exists():
        print(f"Error: {xfer_enum} not found")
        return False
    
    if not eval_engine.exists():
        print(f"Error: {eval_engine} not found")
        return False
    
    print(f"Processing directory: {input_path}")
    if benchmark:
        print(f"Running single benchmark: {benchmark}")
    print(f"Using executables:")
    print(f"  xfer_enum: {xfer_enum}")
    print(f"  eval_engine: {eval_engine}")
    print()
    
    processed_transformers = 0
    skipped_transformers = 0
    
    # Iterate through all subdirectories
    for subfolder in sorted(input_path.iterdir()):
        if not subfolder.is_dir():
            continue
            
        folder_name = subfolder.name
        
        # If a specific benchmark is requested, skip others
        if benchmark and folder_name != benchmark:
            continue
            
        print(f"Processing subfolder: {folder_name}")
        
        # Look for the expected files
        conc_file = subfolder / f"{folder_name}_conc.cpp"
        abs_file = subfolder / f"{folder_name}_abs.cpp"
        
        found_files = False
        
        # Process _conc.cpp file with xfer_enum
        if conc_file.exists():
            found_files = True
            print(f"  Found: {conc_file.name}")
            run_xfer_enum(str(xfer_enum), str(conc_file), script_dir, subfolder)
        
        # Process _abs.cpp file with eval_engine
        if abs_file.exists():
            found_files = True
            print(f"  Found: {abs_file.name}")
            run_eval_engine(str(eval_engine), str(abs_file), script_dir, subfolder)
        
        if found_files:
            processed_transformers += 1
        else:
            print(f"  Skipping: No {folder_name}_conc.cpp or {folder_name}_abs.cpp found")
            skipped_transformers += 1
        
        print()
    
    # Check if specific benchmark was requested but not found
    if benchmark and processed_transformers == 0:
        print(f"Error: Benchmark '{benchmark}' not found in {input_path}")
        return False
    
    print(f"Summary:")
    print(f"  Processed transformers: {processed_transformers}")
    print(f"  Skipped transformers: {skipped_transformers}")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Process directories and run executables on C++ files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python eval_amurth.py /path/to/input/dir
  python eval_amurth.py amurth-result
  python eval_amurth.py amurth-result --benchmark ashr_signed
        """
    )
    
    parser.add_argument(
        "input_dir",
        help="Input directory containing subfolders to process"
    )
    
    parser.add_argument(
        "--benchmark", "-b",
        help="Run only the specified benchmark (subfolder name)"
    )
    
    args = parser.parse_args()
    
    try:
        success = process_directory(args.input_dir, args.benchmark)
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()