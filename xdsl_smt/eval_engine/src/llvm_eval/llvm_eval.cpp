#include <algorithm>
#include <iostream>
#include <optional>
#include <string>
#include <vector>

#include "../Results.h"
#include "../utils.cpp"
#include "../warning_suppresor.h"
#include "cr_tests.h"
#include "im_tests.h"
#include "kb_tests.h"
#include "llvm/IR/ConstantRange.h"
#include "llvm/Support/KnownBits.h"

template <AbstractDomain D, typename LLVM_D>
const Results eval(unsigned int bw, Test<LLVM_D> &tst,
                   const XferWrap<D, LLVM_D> &xfer_wrapper,
                   const std::vector<std::tuple<D, D, D>> &toEval) {
  auto [conc, opCon, xfer] = tst;
  Results r{2};

  D top = D::top(bw);
  for (auto [lhs, rhs, best] : toEval) {
    if (best.isBottom())
      continue;

    bool exact = false;
    unsigned int dis = 0;
    if (xfer) {
      D xfer_res = xfer_wrapper(lhs, rhs, xfer.value());
      exact = xfer_res == best;
      dis = xfer_res.distance(best);
    }
    bool topExact = top == best;
    unsigned int topDis = top.distance(best);

    r.incResult(Result(0, dis, exact, 0, 0), 0);
    r.incResult(Result(0, topDis, topExact, 0, 0), 1);
    r.incCases(0, 0);
  }

  return r;
}

template <typename LLVM_D>
const Test<LLVM_D> makeTest(
    const std::vector<std::tuple<std::string, std::optional<XferFn<LLVM_D>>>>
        &llvmTests,
    const std::string &opName) {

  const auto &[_, llvmOp] =
      *std::find_if(llvmTests.begin(), llvmTests.end(),
                    [&](const auto &x) { return std::get<0>(x) == opName; });

  const auto &[__, concFn, opConFn] =
      *std::find_if(OP_TESTS.begin(), OP_TESTS.end(),
                    [&](const auto &x) { return std::get<0>(x) == opName; });

  return {concFn, opConFn, llvmOp};
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string opName;
  std::getline(std::cin, opName);

  std::vector<std::pair<unsigned int, Results>> results;

  if (domain == "KnownBits") {
    auto [bws, toEval] = getToEval<KnownBits>(fname);
    for (unsigned int i = 0; i < bws.size(); ++i) {
      Test<llvm::KnownBits> test = makeTest<llvm::KnownBits>(KB_TESTS, opName);
      Results r = eval<KnownBits, llvm::KnownBits>(bws[i], test, kb_xfer_wrapper,
                                                toEval[i]);
      results.push_back({bws[i], r});
    }
  } else if (domain == "UConstRange") {
    auto [bws, toEval] = getToEval<UConstRange>(fname);
    for (unsigned int i = 0; i < bws.size(); ++i) {
      Test<llvm::ConstantRange> test =
          makeTest<llvm::ConstantRange>(CR_TESTS, opName);
      Results r = eval<UConstRange, llvm::ConstantRange>(bws[i], test, cr_xfer_wrapper,
                                             toEval[i]);
      results.push_back({bws[i], r});
    }
  } else if (domain == "SConstRange")
    std::cerr << "SConstRange not impl'd yet.\n";
  else if (domain == "IntegerModulo") {
    auto [bws, toEval] = getToEval<IntegerModulo<6>>(fname);
    for (unsigned int i = 0; i < bws.size(); ++i) {
      Test<std::nullopt_t> test = makeTest<std::nullopt_t>(IM_TESTS, opName);
      Results r = eval<IntegerModulo<6>, std::nullopt_t>(bws[i], test, im_xfer_wrapper,
                                             toEval[i]);
      results.push_back({bws[i], r});
    }
  } else
    std::cerr << "Unknown Domain: " << domain << "\n";

  for (auto [bw, r] : results) {
    std::cout << "bw: " << bw << "\n";
    r.print();
    std::cout << "---\n";
  }
}
