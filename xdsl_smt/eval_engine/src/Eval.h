#ifndef Eval_H
#define Eval_H

#include <algorithm>
#include <iterator>
#include <optional>
#include <random>
#include <string>
#include <vector>

#include "APInt.h"
#include "AbstVal.h"
#include "Results.h"
#include "jit.h"
#include "utils.cpp"
#include "warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/Error.h>
SUPPRESS_WARNINGS_END

typedef A::APInt (*ConcOpFn)(A::APInt, A::APInt);
typedef bool (*OpConFn)(A::APInt, A::APInt);

template <AbstractDomain D> class EvalAbstOp {
private:
  ConcOpFn concOp;
  std::optional<OpConFn> opCon;

public:
  EvalAbstOp(ConcOpFn _concOp, std::optional<OpConFn> _opCon)
      : concOp(_concOp), opCon(_opCon) {}

  const D toBestAbst(const D &lhs, const D &rhs) const {
    D res = D::bottom(lhs.bw());

    for (A::APInt lhs_v : lhs.toConcrete())
      for (A::APInt rhs_v : rhs.toConcrete())
        if (!opCon || opCon.value()(lhs_v, rhs_v))
          res = res.join(D::fromConcrete(concOp(lhs_v, rhs_v)));

    return res;
  }

  const std::tuple<D, D, D> genRand(unsigned int bw, std::mt19937 &rng,
                                    bool computeBest) const {
    while (true) {
      const D lhs = D::rand(rng, bw);
      const D rhs = D::rand(rng, bw);
      if (computeBest) {
        const D res = toBestAbst(lhs, rhs);
        if (!res.isBottom())
          return {lhs, rhs, res};
      } else {
        return {lhs, rhs, D::bottom(bw)};
      }
    }
  }
};

// TODO some of the funcs in this class need to be private
template <AbstractDomain D> class Eval {
private:
  // types
  typedef D (*XferFn)(D, D);

  // members
  Jit jit;
  std::vector<XferFn> xferFns;
  std::vector<XferFn> baseFns;

  // methods
  std::vector<D> synFnWrapper(const D &lhs, const D &rhs) const {
    std::vector<D> r;
    std::transform(
        xferFns.begin(), xferFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return D(f(lhs.v, rhs.v)); });
    return r;
  }

  std::vector<D> refFnWrapper(const D &lhs, const D &rhs) const {
    std::vector<D> r;
    std::transform(
        baseFns.begin(), baseFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return D(f(lhs.v, rhs.v)); });
    return r;
  }

public:
  Eval(Jit _jit, const std::vector<std::string> synthFnNames,
       const std::vector<std::string> baseFnNames)
      : jit(std::move(_jit)), xferFns(jit.getFns<XferFn>(synthFnNames)),
        baseFns(jit.getFns<XferFn>(baseFnNames)) {}

  void evalSingle(const D &lhs, const D &rhs, const D &best, Results &r) const {
    // skip the pair if there are no concrete values in the result
    if (best.isBottom())
      return;

    std::vector<D> synth_results(synFnWrapper(lhs, rhs));
    D ref = D::meetAll(refFnWrapper(lhs, rhs), lhs.bw());
    bool solved = ref == best;
    unsigned long baseDis = ref.distance(best);
    for (unsigned int i = 0; i < synth_results.size(); ++i) {
      D synth_after_meet = ref.meet(synth_results[i]);
      bool sound = synth_after_meet.isSuperset(best);
      bool exact = synth_after_meet == best;
      unsigned long dis = synth_after_meet.distance(best);
      unsigned long soundDis = sound ? dis : baseDis;

      r.incResult(Result(sound, dis, exact, solved, soundDis), i);
    }

    r.incCases(solved, baseDis);
  }

  const std::vector<Results>
  eval(const std::vector<std::vector<std::tuple<D, D, D>>> toEval) const {
    std::vector<Results> r(toEval.size(),
                           static_cast<unsigned int>(xferFns.size()));

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, best] = toEval[i][j];
        evalSingle(lhs, rhs, best, r[i]);
      }
    }

    return r;
  }

  const highBwRes evalSingleHighBw(const D &lhs, const D &rhs) const {
    highBwRes r;

    std::vector<D> synth_results(synFnWrapper(lhs, rhs));
    D ref = D::meetAll(refFnWrapper(lhs, rhs), lhs.bw());
    r.first = ref.size().value_or(0);
    for (const auto &syn : synth_results) {
      std::optional<unsigned long> synSize = syn.size();
      std::optional<unsigned long> meetSize = ref.meet(syn).size();

      r.second.push_back(
          {synSize.value_or(0), meetSize.value_or(0), synSize.has_value()});
    }

    return r;
  }

  const std::vector<highBwRes>
  evalHighBw(const std::vector<std::vector<std::tuple<D, D, D>>> toEval) const {
    std::vector<highBwRes> ret;

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      unsigned int sumOfRef = 0;
      std::vector<std::tuple<unsigned long, unsigned long, unsigned long>> r{
          xferFns.size()};

      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, _] = toEval[i][j];
        const highBwRes singleRes = evalSingleHighBw(lhs, rhs);
        sumOfRef += singleRes.first;
        for (unsigned int k = 0; k < singleRes.second.size(); ++k) {
          std::get<0>(r[k]) += std::get<0>(singleRes.second[k]);
          std::get<1>(r[k]) += std::get<1>(singleRes.second[k]);
          std::get<2>(r[k]) += std::get<2>(singleRes.second[k]);
        }
      }

      ret.push_back({sumOfRef, r});
    }

    return ret;
  }

  // TODO handle eval final at high bws,
  // we can make some cooler assumtions if we know that a particular function is
  // sound at 64 bits
  template <typename LLVM_D>
  const std::vector<Results>
  evalFinal(const std::vector<std::vector<std::tuple<D, D, D>>> toEval,
            const std::optional<LLVMXferFn<LLVM_D>> &llvmXfer,
            const XferWrap<D, LLVM_D> &llvmXferWrapper) const {
    std::vector<Results> r(toEval.size(), 4);

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      D top = D::top(std::get<0>(toEval[i][0]).bw());
      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, best] = toEval[i][j];

        if (best.isBottom())
          continue;

        bool topExact = top == best;
        unsigned long topDis = top.distance(best);

        D synth = refFnWrapper(lhs, rhs)[0];
        bool synthExact = synth == best;
        unsigned long synthDis = synth.distance(best);

        bool llvmExact = false;
        unsigned long llvmDis = 0;
        bool meetExact = false;
        unsigned long meetDis = 0;
        if (llvmXfer) {
          D xferRes = llvmXferWrapper(lhs, rhs, llvmXfer.value());
          llvmExact = xferRes == best;
          llvmDis = xferRes.distance(best);

          D meet = xferRes.meet(synth);
          meetExact = meet == best;
          meetDis = meet.distance(best);
        }

        r[i].incResult(Result(0, topDis, topExact, 0, 0), 0);
        r[i].incResult(Result(0, synthDis, synthExact, 0, 0), 1);
        r[i].incResult(Result(0, llvmDis, llvmExact, 0, 0), 2);
        r[i].incResult(Result(0, meetDis, meetExact, 0, 0), 3);
        r[i].incCases(0, 0);
      }
    }

    return r;
  }
};

#endif
