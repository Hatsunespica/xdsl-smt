from os import path
from subprocess import run, PIPE
from xdsl_smt.utils.synthesizer_utils.compare_result import CompareResult

bitwidth = 4


def main():
    base_dir = path.join("xdsl_smt", "eval_engine")
    engine_path = path.join(base_dir, "build", "eval_engine")
    if not path.exists(engine_path):
        raise FileExistsError(f"Eval Engine not found at: {engine_path}")

    eval_output = run(
        [engine_path],
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    def get_float(s: str) -> int:
        return eval(s)[0]

    def get_data(out: str):
        eval_output_lines = out.split("\n")
        name = eval_output_lines[0]
        sounds = get_float(eval_output_lines[2])
        precs = get_float(eval_output_lines[4])
        exact = get_float(eval_output_lines[6])
        num_cases = get_float(eval_output_lines[8])
        unsolved_sounds = get_float(eval_output_lines[10])
        unsolved_precs = get_float(eval_output_lines[12])
        unsolved_exact = get_float(eval_output_lines[14])
        unsolved_num_cases = get_float(eval_output_lines[16])
        base_precs = get_float(eval_output_lines[18])

        return name, CompareResult(
            num_cases,
            sounds,
            exact,
            precs,
            unsolved_num_cases,
            unsolved_sounds,
            unsolved_exact,
            unsolved_precs,
            base_precs,
            bitwidth,
        )

    eval_outputs = eval_output.stdout.split("---\n")
    results = [get_data(x) for x in eval_outputs if x != ""]
    [print(f"{name:<10}", cp.get_exact_prop()) for name, cp in results]


if __name__ == "__main__":
    main()
