#include <functional>
#include <iostream>
#include <string>
#include <vector>

#include "../Results.h"
#include "cr_tests.h"
#include "kb_tests.h"

template <typename D>
const D to_best_abst(const D &lhs, const D &rhs, const concFn &fn,
                     const std::optional<opConFn> &opCon) {
  std::vector<D> crtVals;
  const std::vector<unsigned int> rhss = rhs.toConcrete();

  for (unsigned int lhs_v : lhs.toConcrete())
    for (unsigned int rhs_v : rhss)
      if (!opCon ||
          opCon.value()(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v)))
        crtVals.push_back(D::fromConcrete(
            fn(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v))));

  return D::joinAll(crtVals, lhs.bw());
}

template <typename D, typename D2>
std::vector<std::pair<std::string, Results>>
eval(unsigned int bw, const std::vector<Test<D2>> &tsts,
     XferWrap<D, D2> &xfer_wrapper) {

  std::vector<std::pair<std::string, Results>> r;
  const std::vector<D> fullLattice = D::enumVals(bw);
  D top = D::top(bw);

  for (auto [name, conc, opCon, xfer] : tsts) {
    r.push_back({name, Results{2}});

    for (D lhs : fullLattice) {
      for (D rhs : fullLattice) {
        D best_abstract_res = to_best_abst(lhs, rhs, conc, opCon);

        if (best_abstract_res.isBottom())
          continue;

        bool exact = false;
        if (xfer) {
          D xfer_res = xfer_wrapper(lhs, rhs, xfer.value());
          exact = xfer_res == best_abstract_res;
        }
        bool topExact = top == best_abstract_res;

        r.back().second.incResult(Result(0, 0, exact, 0, 0), 0);
        r.back().second.incResult(Result(0, 0, topExact, 0, 0), 1);
        r.back().second.incCases(0, 0);
      }
    }
  }

  return r;
}

int main() {
  std::string tmpStr;
  std::string domain;
  std::getline(std::cin, domain);
  std::getline(std::cin, tmpStr);
  unsigned int bw = static_cast<unsigned int>(std::stoul(tmpStr));
  std::vector<std::pair<std::string, Results>> results;

  if (domain == "ConstantRange")
    results =
        eval<ConstantRange, llvm::ConstantRange>(bw, cr_tests(), cr_xfer_wrapper);
  else if (domain == "KnownBits")
    results = eval<KnownBits, llvm::KnownBits>(bw, kb_tests(), kb_xfer_wrapper);
  else
    std::cerr << "Unknown Domain: " << domain << "\n";

  for (auto [name, r] : results) {
    std::cout << name << "\n";
    r.print();
    std::cout << "---\n";
  }
}
