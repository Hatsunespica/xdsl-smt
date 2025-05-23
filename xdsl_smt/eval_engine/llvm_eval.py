from os import path
from subprocess import run, PIPE

from xdsl_smt.utils.synthesizer_utils.compare_result import EvalResult, PerBitEvalResult
from xdsl_smt.eval_engine.eval import AbstractDomain


def eval_llvm(domain: AbstractDomain, bitwidth: int) -> list[str]:
    base_dir = path.join("xdsl_smt", "eval_engine")
    engine_path = path.join(base_dir, "build", "llvm_eval")
    if not path.exists(engine_path):
        raise FileExistsError(f"Executable not found at: {engine_path}")

    eval_output = run(
        [engine_path],
        input=f"{domain}\n{bitwidth}\n",
        text=True,
        stdout=PIPE,
        stderr=PIPE,
    )

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr, end="")
        exit(eval_output.returncode)

    def get_floats(s: str) -> list[int]:
        return eval(s)

    def get_data(out: str):
        eval_output_lines = out.split("\n")
        name = eval_output_lines[0]
        sounds = get_floats(eval_output_lines[2])
        precs = get_floats(eval_output_lines[4])
        exact = get_floats(eval_output_lines[6])
        num_cases = get_floats(eval_output_lines[8])
        unsolved_sounds = get_floats(eval_output_lines[10])
        unsolved_precs = get_floats(eval_output_lines[12])
        unsolved_exact = get_floats(eval_output_lines[14])
        unsolved_num_cases = get_floats(eval_output_lines[16])
        base_precs = get_floats(eval_output_lines[18])
        sound_distance = get_floats(eval_output_lines[20])

        return name, [
            PerBitEvalResult(
                num_cases[i],
                sounds[i],
                exact[i],
                precs[i],
                unsolved_num_cases[i],
                unsolved_sounds[i],
                unsolved_exact[i],
                unsolved_precs[i],
                base_precs[i],
                sound_distance[i],
                bitwidth,
            )
            for i in range(2)
        ]

    eval_outputs = eval_output.stdout.split("---\n")
    results = [get_data(x) for x in eval_outputs if x != ""]

    r = [
        (n, EvalResult({bitwidth: cps[0]}), EvalResult({bitwidth: cps[1]}))
        for n, cps in results
    ]

    def fmt_llvm_exact(x: EvalResult) -> str:
        return "n/a   " if x.get_exact_prop() == 0 else f"{x.get_exact_prop():.4f}"

    def fmt_llvm_dis(x: EvalResult) -> str:
        return "n/a   " if x.get_exact_prop() == 0 else f"{x.get_dist():<6}"

    return [
        f"{n:<11}| llvm exact: {fmt_llvm_exact(llvm)} | top exact: {top.get_exact_prop():.4f} | "
        + f"llvm dis: {fmt_llvm_dis(llvm)} | top dis: {top.get_dist():<6}"
        for n, llvm, top in r
    ]


def main():
    bitwidth = 4
    for domain in AbstractDomain:
        output = eval_llvm(domain, bitwidth)
        print(f"Domain: {domain}, BitWidth: {bitwidth}")
        [print(x) for x in output]
        print("")


if __name__ == "__main__":
    main()
