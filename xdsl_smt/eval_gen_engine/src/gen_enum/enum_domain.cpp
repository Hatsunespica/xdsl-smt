#ifndef EnumDomain_H
#define EnumDomain_H

#include <algorithm>
#include <random>
#include <vector>

#include "../AbstVal.h"
#include "../Eval.h"
#include "../jit.h"

template <AbstractDomain D> class EnumDomain {
private:
  Jit jit;
  EvalGenOp<D> evalGenOp;

public:
  EnumDomain(Jit _jit)
      : jit(std::move(_jit)), evalGenOp(jit.getFn<OpConFn>("op_constraint")) {}

  const std::vector<std::vector<std::vector<D>>>
  genLows(const std::vector<unsigned int> &bws) {
    std::vector<std::vector<std::vector<D>>> r;
    std::transform(bws.begin(), bws.end(), std::back_inserter(r),
                   [this](unsigned int bw) { return getFullLattice(bw); });

    return r;
  }

  const std::vector<std::vector<D>> getFullLattice(unsigned int bw) {
    std::vector<std::vector<D>> r;
    const std::vector<D> fullLattice = D::enumVals(bw);

    for (const D &lhs : fullLattice)
      for (const D &rhs : fullLattice) {
        const bool valid = evalGenOp.checkAbstCon(lhs, rhs);
        if (valid) {
          std::vector<D> sample;
          sample.reserve(2);
          sample.push_back(lhs);
          sample.push_back(rhs);
          r.push_back(std::move(sample));
        }
      }

    return r;
  }
};

#endif
