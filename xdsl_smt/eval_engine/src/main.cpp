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
void handleDomain(
    const std::string &dataDir, const std::vector<std::string> &synNames,
    const std::vector<std::string> &bFnNames, const std::string &srcCode,
    const std::string &opName,
    const std::vector<std::tuple<std::string, std::optional<XferFn<LLVM_D>>>>
        &llvmTests,
    const XferWrap<D, LLVM_D> &llvmXferWrapper) {
  Jit jit(srcCode);
  auto [low, med, high] = getToEval<D>(dataDir);

  Eval<D> e(std::move(jit), synNames, bFnNames);
  if (opName == "") {
    for (const auto &x : e.eval(high))
      std::cout << x;
    for (const auto &x : e.eval(med))
      std::cout << x;
    for (const auto &x : e.eval(low))
      std::cout << x;
  } else {
    std::optional<XferFn<LLVM_D>> llvmXfer = makeTest(llvmTests, opName);

    for (const auto &x : e.evalFinal(high, llvmXfer, llvmXferWrapper))
      std::cout << x;
    for (const auto &x : e.evalFinal(med, llvmXfer, llvmXferWrapper))
      std::cout << x;
    for (const auto &x : e.evalFinal(low, llvmXfer, llvmXferWrapper))
      std::cout << x;
  }
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string opName;
  std::getline(std::cin, opName);

  std::vector<std::string> synNames = parseStrList(std::cin);
  std::vector<std::string> bFnNames = parseStrList(std::cin);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  if (opName != "" && synNames.size() != 0) {
    std::cerr << "No synthed functions allowed on final eval\n";
    exit(1);
  }

  if (opName != "" && bFnNames.size() != 1) {
    std::cerr << "Only one reference function allowed on final eval\n";
    exit(1);
  }

  if (domain == "KnownBits") {
    handleDomain<KnownBits, llvm::KnownBits>(fname, synNames, bFnNames,
                                             fnSrcCode, opName, KB_TESTS,
                                             kb_xfer_wrapper);
  } else if (domain == "UConstRange") {
    handleDomain<UConstRange, llvm::ConstantRange>(fname, synNames, bFnNames,
                                                   fnSrcCode, opName, UCR_TESTS,
                                                   ucr_xfer_wrapper);
  } else if (domain == "SConstRange") {
    handleDomain<SConstRange, std::nullopt_t>(fname, synNames, bFnNames,
                                              fnSrcCode, opName, EMPTY_TESTS,
                                              scr_xfer_wrapper);
  } else if (domain == "IntegerModulo") {
    handleDomain<IntegerModulo<6>, std::nullopt_t>(
        fname, synNames, bFnNames, fnSrcCode, opName, EMPTY_TESTS,
        im_xfer_wrapper);
  } else {
    std::cerr << "Unknown domain: " << domain << "\n";
    exit(1);
  }

  return 0;
}
