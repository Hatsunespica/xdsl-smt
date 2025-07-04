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
                                    int numConcSamples) const {
    while (true) {
      const D lhs = D::rand(rng, bw);
      const D rhs = D::rand(rng, bw);
      if (numConcSamples == -1) {
        const D res = toBestAbst(lhs, rhs);
        if (!res.isBottom())
          return {lhs, rhs, res};
      } else {
        D res = D::bottom(bw);

        for (int i = 0; i < numConcSamples; ++i) {
          const A::APInt lhsConc = lhs.getRandConcrete(rng);
          const A::APInt rhsConc = rhs.getRandConcrete(rng);
          if (!opCon || opCon.value()(lhsConc, rhsConc))
            res = res.join(D::fromConcrete(concOp(lhsConc, rhsConc)));
        }

        return {lhs, rhs, res};
      }
    }
  }
};

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

  void evalSingle(const D &lhs, const D &rhs, const D &best, Results &r) const {
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

public:
  Eval(Jit _jit, const std::vector<std::string> synthFnNames,
       const std::vector<std::string> baseFnNames)
      : jit(std::move(_jit)), xferFns(jit.getFns<XferFn>(synthFnNames)),
        baseFns(jit.getFns<XferFn>(baseFnNames)) {}

  const std::vector<Results> eval(const ToEval<D> toEval) const {
    std::vector<Results> r;

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      r.push_back(
          {static_cast<unsigned int>(xferFns.size()), getBw(toEval[i])});

      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, best] = toEval[i][j];
        evalSingle(lhs, rhs, best, r[i]);
      }
    }

    return r;
  }

  template <typename LLVM_D>
  const std::vector<Results>
  evalFinal(const ToEval<D> toEval,
            const std::optional<LLVMXferFn<LLVM_D>> &llvmXfer,
            const XferWrap<D, LLVM_D> &llvmXferWrapper) const {
    std::vector<Results> r;

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      r.push_back({4, getBw(toEval[i])});

      D top = D::top(getBw(toEval[i]));
      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, best] = toEval[i][j];

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
