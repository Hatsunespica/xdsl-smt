#include <functional>
#include <iostream>
#include <optional>
#include <string>
#include <vector>

#include "../Results.h"
#include "cr_tests.h"
#include "im_tests.h"
#include "kb_tests.h"

template <typename D>
const D to_best_abst(const D &lhs, const D &rhs, const concFn &fn,
                     const std::optional<opConFn> &opCon) {
  std::vector<D> crtVals;
  const std::vector<A::APInt> rhss = rhs.toConcrete();

  for (A::APInt lhs_v : lhs.toConcrete())
    for (A::APInt rhs_v : rhss)
      if (!opCon || opCon.value()(lhs_v, rhs_v))
        crtVals.push_back(D::fromConcrete(fn(lhs_v, rhs_v)));

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
        unsigned int dis = 0;
        if (xfer) {
          D xfer_res = xfer_wrapper(lhs, rhs, xfer.value());
          exact = xfer_res == best_abstract_res;
          dis = xfer_res.distance(best_abstract_res);
        }
        bool topExact = top == best_abstract_res;
        unsigned int topDis = top.distance(best_abstract_res);

        r.back().second.incResult(Result(0, dis, exact, 0, 0), 0);
        r.back().second.incResult(Result(0, topDis, topExact, 0, 0), 1);
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

  if (domain == "KnownBits")
    results = eval<KnownBits, llvm::KnownBits>(bw, kb_tests(), kb_xfer_wrapper);
  else if (domain == "UConstRange")
    results = eval<UConstRange, llvm::ConstantRange>(bw, cr_tests(),
                                                       cr_xfer_wrapper);
  else if (domain == "SConstRange")
    std::cerr << "SConstRange not impl'd yet.\n";
  else if (domain == "IntegerModulo")
    results =
        eval<IntegerModulo<6>, std::nullopt_t>(bw, im_tests(), im_xfer_wrapper);
  else
    std::cerr << "Unknown Domain: " << domain << "\n";

  for (auto [name, r] : results) {
    std::cout << name << "\n";
    r.print();
    std::cout << "---\n";
  }
}
