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
  EvalAbstOp<D> evalAbstOp;

public:
  EnumDomain(Jit _jit)
      : jit(std::move(_jit)),
        evalAbstOp(jit.getFn<ConcOpFn>("concrete_op"),
                   jit.getOptFn<OpConFn>("op_constraint")) {}

  const ToEval<D> genLows(const std::vector<unsigned int> &bws) {
    std::vector<std::vector<std::tuple<D, D, D>>> r;
    std::transform(bws.begin(), bws.end(), std::back_inserter(r),
                   [this](unsigned int bw) { return getFullLattice(bw); });

    return r;
  }

  const ToEval<D>
  genMids(const std::vector<std::pair<unsigned int, unsigned int>> &bws,
          std::mt19937 &rng) {

    std::vector<std::vector<std::tuple<D, D, D>>> r;
    std::transform(bws.begin(), bws.end(), std::back_inserter(r),
                   [this, &rng](std::pair<unsigned int, unsigned int> bw) {
                     return sampleLattice(bw.first, bw.second, rng, -1);
                   });

    return r;
  }

  const ToEval<D> genHighs(
      const std::vector<std::tuple<unsigned int, unsigned int, unsigned int>>
          &bws,
      std::mt19937 &rng) {

    std::vector<std::vector<std::tuple<D, D, D>>> r;
    std::transform(
        bws.begin(), bws.end(), std::back_inserter(r),
        [this, &rng](std::tuple<unsigned int, unsigned int, unsigned int> bw) {
          return sampleLattice(std::get<0>(bw), std::get<1>(bw), rng,
                               static_cast<int>(std::get<2>(bw)));
        });

    return r;
  }

  const std::vector<std::tuple<D, D, D>> sampleLattice(unsigned int bw,
                                                       unsigned int samples,
                                                       std::mt19937 &rng,
                                                       int concSamples) {
    std::vector<std::tuple<D, D, D>> r;
    for (unsigned int i = 0; i < samples; ++i)
      r.push_back(evalAbstOp.genRand(bw, rng, concSamples));

    return r;
  }

  const std::vector<std::tuple<D, D, D>> getFullLattice(unsigned int bw) {
    std::vector<std::tuple<D, D, D>> r;
    const std::vector<D> fullLattice = D::enumVals(bw);

    for (const D &lhs : fullLattice)
      for (const D &rhs : fullLattice) {
        const D best = evalAbstOp.toBestAbst(lhs, rhs);
        if (!best.isBottom())
          r.push_back({lhs, rhs, best});
      }

    return r;
  }
};

#endif
