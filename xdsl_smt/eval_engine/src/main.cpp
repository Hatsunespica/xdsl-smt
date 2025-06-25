#include <iostream>
#include <iterator>
#include <optional>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "jit.h"
#include "llvm_tests.h"
#include "utils.cpp"

template <typename D, typename LLVM_D>
const std::pair<std::vector<unsigned int>, std::vector<Results>> handleDomain(
    const std::string &dataDir, const std::vector<std::string> &synNames,
    const std::vector<std::string> &bFnNames, const std::string &srcCode,
    const std::string &opName,
    const std::vector<std::tuple<std::string, std::optional<XferFn<LLVM_D>>>>
        &llvmTests,
    const XferWrap<D, LLVM_D> &llvmXferWrapper) {
  Jit jit(srcCode);
  auto [bws, toEval] = getToEval<D>(dataDir);
  Eval<D> e(std::move(jit), synNames, bFnNames);
  if (opName == "") {
    return {bws, e.eval(toEval)};
  } else {
    std::optional<XferFn<LLVM_D>> llvmXfer = makeTest(llvmTests, opName);
    return {bws, e.evalFinal(toEval, llvmXfer, llvmXferWrapper)};
  }
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string opName;
  std::getline(std::cin, opName);

  std::vector<std::string> synNames = getSplitLine(std::cin);
  std::vector<std::string> bFnNames = getSplitLine(std::cin);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  if (opName != "" && synNames.size() != 0) {
    std::cerr << "No synthed functions allowed on final eval\n";
    exit(1);
  }

  if (opName != "" && bFnNames.size() != 1) {
    std::cerr << "Only one reference function allowed on final eval\n";
    exit(1);
  }

  std::pair<std::vector<unsigned int>, std::vector<Results>> r;

  if (domain == "KnownBits") {
    r = handleDomain<KnownBits, llvm::KnownBits>(fname, synNames, bFnNames,
                                                 fnSrcCode, opName, KB_TESTS,
                                                 kb_xfer_wrapper);
  } else if (domain == "UConstRange") {
    r = handleDomain<UConstRange, llvm::ConstantRange>(
        fname, synNames, bFnNames, fnSrcCode, opName, UCR_TESTS,
        ucr_xfer_wrapper);
  } else if (domain == "SConstRange") {
    r = handleDomain<SConstRange, std::nullopt_t>(
        fname, synNames, bFnNames, fnSrcCode, opName, EMPTY_TESTS,
        scr_xfer_wrapper);
  } else if (domain == "IntegerModulo") {
    r = handleDomain<IntegerModulo<6>, std::nullopt_t>(
        fname, synNames, bFnNames, fnSrcCode, opName, EMPTY_TESTS,
        im_xfer_wrapper);
  } else {
    std::cerr << "Unknown domain: " << domain << "\n";
    exit(1);
  }

  for (unsigned int i = 0; i < r.first.size(); ++i) {
    std::cout << "bw: " << r.first[i] << "\n";
    r.second[i].print();
    std::cout << "---\n";
  }

  return 0;
}
