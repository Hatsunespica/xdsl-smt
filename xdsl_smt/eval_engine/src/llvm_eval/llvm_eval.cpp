#include <iostream>
#include <vector>

#include "../Results.h"
#include "cr_tests.h"
#include "kb_tests.h"

// TODO parameterize the to best abst fn too
// TODO parameterize, and return res instead of printing here
void eval(unsigned int bw) {
  const std::vector<KnownBits> fullLattice = KnownBits::enumVals(bw);
  KnownBits top = KnownBits::top(bw);

  for (auto [name, conc, opCon, xfer] : kb_tests) {
    Results r{2};

    for (KnownBits lhs : fullLattice) {
      for (KnownBits rhs : fullLattice) {
        KnownBits best_abstract_res = to_best_kb_abst(lhs, rhs, conc, opCon);

        if (best_abstract_res.isBottom())
          continue;

        KnownBits xfer_res = kb_xfer_wrapper(lhs, rhs, xfer);
        bool exact = xfer_res == best_abstract_res;
        bool topExact = top == best_abstract_res;

        r.incResult(Result(0, 0, exact, 0, 0), 0);
        r.incResult(Result(0, 0, topExact, 0, 0), 1);
        r.incCases(0, 0);
      }
    }

    std::cout << name << "\n";
    r.print();
    std::cout << "---\n";
  }
}

void eval_cr(unsigned int bw) {
  const std::vector<ConstantRange> fullLattice = ConstantRange::enumVals(bw);
  ConstantRange top = ConstantRange::top(bw);

  for (auto [name, conc, opCon, xfer] : cr_tests) {
    Results r{2};

    for (ConstantRange lhs : fullLattice) {
      for (ConstantRange rhs : fullLattice) {
        ConstantRange best_abstract_res =
            to_best_cr_abst(lhs, rhs, conc, opCon);

        if (best_abstract_res.isBottom())
          continue;

        ConstantRange xfer_res = cr_xfer_wrapper(lhs, rhs, xfer);
        bool exact = xfer_res == best_abstract_res;
        bool topExact = top == best_abstract_res;

        r.incResult(Result(0, 0, exact, 0, 0), 0);
        r.incResult(Result(0, 0, topExact, 0, 0), 1);
        r.incCases(0, 0);
      }
    }

    std::cout << name << "\n";
    r.print();
    std::cout << "---\n";
  }
}

int main() {
  std::string tmpStr;
  std::string domain;
  std::getline(std::cin, domain);
  std::getline(std::cin, tmpStr);
  unsigned int bw = static_cast<unsigned int>(std::stoul(tmpStr));

  eval_cr(bw);
}
