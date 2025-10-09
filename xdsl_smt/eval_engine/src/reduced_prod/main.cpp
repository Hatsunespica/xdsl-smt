#include <iostream>
#include <tuple>
#include <vector>

#include "../Results.h"
#include "../jit.h"
#include "../llvm_tests.h"
#include "../warning_suppresor.h"
#include "RPEval.h"

SUPPRESS_WARNINGS_BEGIN
#include "llvm/IR/ConstantRange.h"
#include "llvm/Support/KnownBits.h"
SUPPRESS_WARNINGS_END

// void brute_force_tester() {
//   std::vector<std::string> bFnNames = parseStrList(std::cin);
//   std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
//   Jit jit(fnSrcCode);
//   RPEval e{std::move(jit), bFnNames[0], bFnNames[1], bFnNames[2]};
//
//   const std::vector<Product> fullLattice = e.enumVals(4);
//
//   int i = 0;
//   unsigned long total = 0;
//   for (const Product &latVal : fullLattice) {
//     Product myReduce = reduce(latVal);
//     Product bruteReduced = bruteReduce(latVal);
//     ++total;
//     if (myReduce != bruteReduced) {
//       ++i;
//       std::cout << "##########################################\n";
//       std::cout << "OG kb: " << latVal.kb.display() << "\n";
//       std::cout << "OG ucr: " << latVal.ucr.display() << "\n";
//       std::cout << "OG scr: " << latVal.scr.display() << "\n";
//       std::cout << "---\n";
//       std::cout << "my kb: " << myReduce.kb.display() << "\n";
//       std::cout << "my ucr: " << myReduce.ucr.display() << "\n";
//       std::cout << "my scr: " << myReduce.scr.display() << "\n";
//       std::cout << "---\n";
//       std::cout << "br kb: " << bruteReduced.kb.display() << "\n";
//       std::cout << "br ucr: " << bruteReduced.ucr.display() << "\n";
//       std::cout << "br scr: " << bruteReduced.scr.display() << "\n";
//       std::cout << "##########################################\n";
//     }
//   }
//   std::cout << "num wrong: " << i << "\n";
//   std::cout << "total: " << total << "\n";
// }

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

  std::vector<Results> r = e.evalFinal(toEval, llvmKbXfer);
  for (auto x : r)
    x.print(std::cout, KnownBits::maxDist);

  return 0;
}
