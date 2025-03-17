import os
from os import path
from subprocess import run, PIPE
from enum import Enum, auto

from xdsl_smt.utils.compare_result import CompareResult

# from xdsl_smt.utils.func_with_cpp import FuncWithCpp


class AbstractDomain(Enum):
    KnownBits = auto()
    ConstantRange = auto()

    def __str__(self) -> str:
        return self.name


llvm_bin_dir: str = ""


def get_build_cmd() -> list[str]:
    has_libclang = (
        run(["ldconfig", "-p"], stdout=PIPE)
        .stdout.decode("utf-8")
        .find("libclang.so.19")
    )

    llvm_include_dir = (
        run(
            [llvm_bin_dir + "llvm-config", "--includedir"],
            stdout=PIPE,
        )
        .stdout.decode("utf-8")
        .split("\n")[0]
    )

    if llvm_bin_dir != "" or has_libclang == -1:
        all_llvm_link_flags = (
            run(
                [
                    llvm_bin_dir + "llvm-config",
                    "--ldflags",
                    "--libdir",
                    "--libs",
                    "--system-libs",
                ],
                stdout=PIPE,
            )
            .stdout.decode("utf-8")
            .split("\n")
        )
        all_llvm_link_flags = [x for x in all_llvm_link_flags if x != ""]
        lib_dir = all_llvm_link_flags[1]
        llvm_link_libs = all_llvm_link_flags[2].split(" ")

        llvm_link_flags = [all_llvm_link_flags[0]] + [
            x for x in llvm_link_libs if ("LLVMSupport" in x)
        ]

        build_cmd = [
            llvm_bin_dir + "clang++",
            "-std=c++20",
            # "-O1",
            f"-I{llvm_include_dir}",
            f"-I{llvm_bin_dir}../include",
            "-L",
            f"{llvm_bin_dir}../lib",
            "../src/main.cpp",
            "-o",
            "EvalEngine",
            f"-Wl,-rpath,{lib_dir}",
        ] + llvm_link_flags
    else:
        llvm_link_flags = (
            run(
                ["llvm-config", "--ldflags", "--libs", "--system-libs"],
                stdout=PIPE,
            )
            .stdout.decode("utf-8")
            .split("\n")
        )
        llvm_link_flags = [x for x in llvm_link_flags if x != ""]
        build_cmd = [
            "clang++",
            "-std=c++20",
            # "-O1",
            f"-I{llvm_include_dir}",
            "../src/main.cpp",
            "-o",
            "EvalEngine",
        ] + llvm_link_flags

    return build_cmd


def make_xfer_header(concrete_op: str) -> str:
    includes = """
    #include <llvm/ADT/APInt.h>
    #include <vector>
    #include "AbstVal.cpp"
    using llvm::APInt;
    """

    conc_op_wrapper = """
    unsigned int concrete_op_wrapper(const unsigned int a, const unsigned int b) {
      return concrete_op(APInt(32, a), APInt(32, b)).getZExtValue();
    }
    """

    return includes + concrete_op + conc_op_wrapper


def make_func_call(x: str) -> str:
    return f"const std::vector<llvm::APInt> res_v_{x} = {x}" + "(lhs.v, rhs.v);"


def make_func_call_cond(x: str) -> str:
    return f"const bool res_v_{x} = {x}" + "(lhs.v, rhs.v);"


def make_res(x: str) -> str:
    return f"Domain res_{x}(res_v_{x});"


def make_res_cond(x: str) -> str:
    return f"bool res_{x};\nres_{x} = res_v_{x};\n"


def make_xfer_wrapper(func_names: list[str], wrapper_name: str) -> str:
    func_sig = (
        "std::vector<Domain> "
        + wrapper_name
        + "_wrapper(const Domain &lhs, const Domain &rhs)"
    )

    func_calls = "\n".join([make_func_call(x) for x in func_names])
    results = "\n".join([make_res(x) for x in func_names])
    return_elems = ", ".join([f"res_{x}" for x in func_names])
    return_statment = "return {%s};" % return_elems

    return func_sig + "{" + f"\n{func_calls}\n{results}\n{return_statment}" + "}"


def make_conds_wrapper(cond_names: list[str | None], wrapper_name: str) -> str:
    func_sig = (
        "std::vector<bool> "
        + wrapper_name
        + "_wrapper(const Domain &lhs, const Domain &rhs)"
    )
    func_calls = "\n".join(
        [make_func_call_cond(x) for x in cond_names if x is not None]
    )
    results = "\n".join([make_res_cond(x) for x in cond_names if x is not None])
    return_elems = ", ".join(
        [("true" if x is None else f"res_{x}") for x in cond_names]
    )
    return_statment = "return {%s};" % return_elems

    return func_sig + "{" + f"\n{func_calls}\n{results}\n{return_statment}" + "}"


def rename(
    srcs: list[str | None], names: list[str | None], label: str = ""
) -> tuple[list[str | None], list[str | None]]:
    """
    rename the transfer functions
    """
    new_srcs: list[str | None] = []
    new_names: list[str | None] = []
    for i, (nm, src) in enumerate(zip(names, srcs)):
        if src is None:
            new_srcs.append(None)
        else:
            new_srcs.append(src.replace(nm, f"{nm}_{label}{i}"))

    for i, nm in enumerate(names):
        if nm is None:
            new_names.append(None)
        else:
            new_names.append(nm)
    return new_srcs, new_names


def rename_no_none(
    srcs: list[str], names: list[str], label: str = ""
) -> tuple[list[str], list[str]]:
    """
    the version of rename that ensures no None values are in the lists
    """
    new_srcs = [
        src.replace(nm, f"{nm}_{label}{i}")
        for i, (nm, src) in enumerate(zip(names, srcs))
    ]
    new_names = [f"{nm}_{label}{i}" for i, nm in enumerate(names)]
    return new_srcs, new_names


def eval_transfer_func(
    xfer_names: list[str],
    xfer_srcs: list[str],
    cond_names: list[str | None],
    cond_srcs: list[str | None],
    concrete_op_expr: str,
    ref_xfer_names: list[str],
    ref_xfer_srcs: list[str],
    ref_cond_names: list[str | None],
    ref_cond_srcs: list[str | None],
    domain: AbstractDomain,
    bitwidth: int,
    helper_funcs: list[str] | None = None,
) -> list[CompareResult]:
    func_wrapper_name = "synth_function"
    cond_wrapper_name = "synth_cond"
    ref_func_wrapper_name = "ref_function"
    ref_cond_wrapper_name = "ref_cond"
    ref_func_suffix = "BASE"
    cond_suffix = "COND"
    ref_cond_suffix = "BASE_COND"

    if not cond_names:
        cond_names = [None] * len(xfer_names)
        cond_srcs = [None] * len(xfer_names)
    if not ref_cond_names:
        ref_cond_names = [None] * len(ref_xfer_names)
        ref_cond_srcs = [None] * len(ref_xfer_names)

    assert len(xfer_names) == len(xfer_srcs) == len(cond_names) == len(cond_srcs)
    assert (
        len(ref_xfer_names)
        == len(ref_xfer_names)
        == len(ref_cond_names)
        == len(ref_cond_srcs)
    )

    transfer_func_header = make_xfer_header(concrete_op_expr)
    transfer_func_header += f"\ntypedef {domain}<{bitwidth}> Domain;\n"
    transfer_func_header += f"\nunsigned int numFuncs = {len(xfer_names)};\n"

    ref_xfer_srcs, ref_xfer_names = rename_no_none(
        ref_xfer_srcs, ref_xfer_names, ref_func_suffix
    )
    ref_xfer_func_wrapper = make_xfer_wrapper(ref_xfer_names, ref_func_wrapper_name)

    ref_cond_srcs, ref_cond_names = rename(
        ref_cond_srcs, ref_cond_names, ref_cond_suffix
    )
    ref_cond_wrapper = make_conds_wrapper(ref_cond_names, ref_cond_wrapper_name)

    xfer_srcs, xfer_names = rename_no_none(xfer_srcs, xfer_names)
    xfer_func_wrapper = make_xfer_wrapper(xfer_names, func_wrapper_name)

    cond_srcs, cond_names = rename(cond_srcs, cond_names, cond_suffix)
    cond_wrapper = make_conds_wrapper(cond_names, cond_wrapper_name)

    all_xfer_src = "\n".join(
        xfer_srcs
        + ref_xfer_srcs
        + [s for s in cond_srcs if s is not None]
        + [s for s in ref_cond_srcs if s is not None]
    )

    all_helper_funcs_src = ""
    if helper_funcs:
        all_helper_funcs_src = "\n".join(helper_funcs)

    base_dir = path.join("xdsl_smt", "eval_engine")
    cur_dir = os.getcwd()
    synth_code_path = path.join(cur_dir, base_dir, "src", "synth.cpp")

    with open(synth_code_path, "w") as f:
        f.write(
            f"{transfer_func_header}\n{all_helper_funcs_src}\n{all_xfer_src}\n{xfer_func_wrapper}\n{ref_xfer_func_wrapper}\n{cond_wrapper}\n{ref_cond_wrapper}\n"
        )

    try:
        os.mkdir(path.join(cur_dir, base_dir, "build"))
    except FileExistsError:
        pass

    os.chdir(path.join(base_dir, "build"))

    run(get_build_cmd(), stdout=PIPE)
    eval_output = run(["./EvalEngine"], stdout=PIPE, stderr=PIPE)

    if eval_output.returncode != 0:
        print("EvalEngine failed with this error:")
        print(eval_output.stderr.decode("utf-8"), end="")
        exit(eval_output.returncode)

    def get_floats(s: str) -> list[int]:
        return eval(s)

    os.chdir(cur_dir)

    eval_output_lines = eval_output.stdout.decode("utf-8").split("\n")
    sounds = get_floats(eval_output_lines[1])
    precs = get_floats(eval_output_lines[3])
    exact = get_floats(eval_output_lines[5])
    num_cases = get_floats(eval_output_lines[7])
    unsolved_sounds = get_floats(eval_output_lines[9])
    unsolved_precs = get_floats(eval_output_lines[11])
    unsolved_exact = get_floats(eval_output_lines[13])
    unsolved_num_cases = get_floats(eval_output_lines[15])
    base_precs = get_floats(eval_output_lines[17])

    assert len(sounds) > 0, f"No output from EvalEngine: {eval_output}"
    assert (
        len(sounds)
        == len(precs)
        == len(exact)
        == len(num_cases)
        == len(unsolved_sounds)
        == len(unsolved_precs)
        == len(unsolved_exact)
        == len(unsolved_num_cases)
        == len(base_precs)
    ), f"EvalEngine output mismatch: {eval_output}"

    cmp_results: list[CompareResult] = [
        CompareResult(
            num_cases[i],
            sounds[i],
            exact[i],
            precs[i],
            unsolved_num_cases[i],
            unsolved_sounds[i],
            unsolved_exact[i],
            unsolved_precs[i],
            base_precs[i],
            bitwidth,
        )
        for i in range(len(sounds))
    ]

    return cmp_results


def main():
    constraint_func = """
    bool op_constraint(APInt _arg0, APInt _arg1){
        return true;
    }
    """

    concrete_op = """
    APInt concrete_op(APInt a, APInt b) {
        return a+b;
    }
    """

    transfer_func_name = "cr_add"
    transfer_func_src = """
std::vector<APInt> cr_add(std::vector<APInt> arg0, std::vector<APInt> arg1) {
  bool res0_ov;
  bool res1_ov;
  APInt res0 = arg0[0].uadd_ov(arg1[0], res0_ov);
  APInt res1 = arg0[1].uadd_ov(arg1[1], res1_ov);
  if (res0.ugt(res1) || (res0_ov ^ res1_ov))
    return {llvm::APInt::getMinValue(arg0[0].getBitWidth()),
            llvm::APInt::getMaxValue(arg0[0].getBitWidth())};
  return {res0, res1};
}
    """

    names = [transfer_func_name]
    srcs = [transfer_func_src]
    ref_names: list[str] = []  # TODO
    ref_srcs: list[str] = []  # TODO
    results = eval_transfer_func(
        names,
        srcs,
        [],
        [],
        f"{concrete_op}\n{constraint_func}",
        ref_names,
        ref_srcs,
        [],
        [],
        AbstractDomain.ConstantRange,
        4,
    )

    for res in results:
        print(res)
        # commented this because the cost depends on both the compare result and the synthesis context
        # print(f"cost:                  {res.get_cost():.04f}")
        print(f"sound prop:            {res.get_sound_prop():.04f}")
        print(f"exact prop:            {res.get_exact_prop():.04f}")
        print(f"edit dis avg:          {res.get_edit_dis_avg():.04f}")
        print(f"unsolved exact prop:   {res.get_unsolved_exact_prop():.04f}")
        print(f"unsolved sound prop:   {res.get_unsolved_sound_prop():.04f}")
        print(f"unsolved edit dis avg: {res.get_unsolved_edit_dis_avg():.04f}")


if __name__ == "__main__":
    main()
