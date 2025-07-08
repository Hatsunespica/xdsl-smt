#include <tuple>
#include <vector>

#include "../llvm_tests.h"
#include "../warning_suppresor.h"
#include "RPEval.h"

SUPPRESS_WARNINGS_BEGIN
#include "llvm/IR/ConstantRange.h"
#include "llvm/Support/KnownBits.h"
SUPPRESS_WARNINGS_END

int main() {
  std::vector<unsigned int> lbws = parseIntList(std::cin);
  std::vector<std::pair<unsigned int, unsigned int>> mbws =
      parsePairs(std::cin);
  std::vector<std::tuple<unsigned int, unsigned int, unsigned int>> hbws =
      parseTriples(std::cin);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int seed = static_cast<unsigned int>(std::stoul(tmpStr));
  std::mt19937 rng(seed);

  std::string opName;
  std::getline(std::cin, opName);
  std::vector<std::string> bFnNames = parseStrList(std::cin);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  RPEval e{std::move(jit), bFnNames[0], bFnNames[1], bFnNames[2]};
  const std::vector<std::vector<std::tuple<Product, Product, Product>>> lows =
      e.genLows(lbws);

  const std::vector<std::vector<std::tuple<Product, Product, Product>>> mids =
      e.genMids(mbws, rng);

  const std::vector<std::vector<std::tuple<Product, Product, Product>>> highs =
      e.genHighs(hbws, rng);

  std::vector<std::vector<std::tuple<Product, Product, Product>>> toEval;
  toEval.insert(toEval.end(), lows.begin(), lows.end());
  toEval.insert(toEval.end(), mids.begin(), mids.end());
  toEval.insert(toEval.end(), highs.begin(), highs.end());

  std::optional<XferFn<llvm::KnownBits>> llvmKbXfer =
      makeTest(KB_TESTS, opName);
  std::optional<XferFn<llvm::ConstantRange>> llvmCrXfer =
      makeTest(UCR_TESTS, opName);

  std::vector<Results> r = e.evalFinal(toEval, llvmKbXfer, llvmCrXfer);
  for (auto x : r)
    x.print(std::cout, KnownBits::maxDist);
  // TODO fix the dist thing
  // for (auto [_, crRes] : r)
  //   crRes.print(std::cout, UConstRange::maxDist);

  return 0;
}
