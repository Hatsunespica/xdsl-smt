#ifndef Eval_H
#define Eval_H

#include <algorithm>
#include <iterator>
#include <optional>
#include <random>
#include <string>
#include <vector>

#include "APInt.h"
#include "Results.h"
#include "jit.h"
#include "warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/Error.h>
SUPPRESS_WARNINGS_END

// TODO rename all the classes
// TODO maybe hide these types in a class
typedef A::APInt (*ConcOpFn)(A::APInt, A::APInt);
typedef bool (*OpConFn)(A::APInt, A::APInt);

template <typename D> class EnumEval {
private:
  std::optional<OpConFn> opCon;
  ConcOpFn concOp;

public:
  EnumEval(ConcOpFn _concOp, std::optional<OpConFn> _opCon)
      : opCon(_opCon), concOp(_concOp) {}

  const D toBestAbst(const D &lhs, const D &rhs) {
    D res = D::bottom(lhs.bw());

    for (A::APInt lhs_v : lhs.toConcrete())
      for (A::APInt rhs_v : rhs.toConcrete())
        if (!opCon || opCon.value()(lhs_v, rhs_v))
          res = res.join(D::fromConcrete(concOp(lhs_v, rhs_v)));

    return res;
  }

  const std::tuple<D, D, D> genRand(unsigned int ebw, std::mt19937 &rng) {
    while (true) {
      D lhs = D(rng, ebw);
      D rhs = D(rng, ebw);
      D res = toBestAbst(lhs, rhs);
      if (!res.isBottom())
        return {lhs, rhs, res};
    }
  }
};

template <typename D> class EnumXfer {
private:
  // members
  Jit jit;
  unsigned int lbw;
  unsigned int ubw;
  EnumEval<D> enumEval;

public:
  EnumXfer(Jit _jit, unsigned int _lbw, unsigned int _ubw)
      : jit(std::move(_jit)), lbw(_lbw), ubw(_ubw), enumEval(nullptr, nullptr) {
    ConcOpFn concOpFn = jit.getFn<ConcOpFn>("concrete_op");
    std::optional<OpConFn> opConFn = jit.getOptFn<OpConFn>("op_constraint");
    enumEval = EnumEval<D>(concOpFn, opConFn);
  }

  const std::vector<std::tuple<D, D, D>>
  genRands(unsigned int samples, unsigned int ebw, std::mt19937 &rng) {
    std::vector<std::tuple<D, D, D>> r;
    for (unsigned int i = 0; i < samples; ++i)
      r.push_back(enumEval.genRand(ebw, rng));

    return r;
  }

  const std::vector<std::tuple<D, D, D>> genLattice(unsigned int ebw) {
    std::vector<std::tuple<D, D, D>> r;
    const std::vector<D> fullLattice = D::enumVals(ebw);

    for (D lhs : fullLattice)
      for (D rhs : fullLattice)
        r.push_back({lhs, rhs, enumEval.toBestAbst(lhs, rhs)});

    return r;
  }

  const std::vector<std::vector<std::tuple<D, D, D>>> genAllBws() {
    std::vector<std::vector<std::tuple<D, D, D>>> r;

    for (unsigned int ebw = lbw; ebw <= ubw; ++ebw)
      r.push_back(genLattice(ebw));

    return r;
  }

  const std::vector<std::vector<std::tuple<D, D, D>>>
  genAllBwsRand(unsigned int seed, unsigned int samples) {
    std::vector<std::vector<std::tuple<D, D, D>>> r;
    std::mt19937 rng(seed);

    for (unsigned int ebw = lbw; ebw <= std::min(ubw, 4u); ++ebw)
      r.push_back(genLattice(ebw));

    if (ubw > 4) {
      unsigned int tmplbw = std::max(5u, lbw);
      unsigned int sample_per_bw = samples / (ubw - tmplbw + 1);
      for (unsigned int ebw = tmplbw; ebw <= ubw; ++ebw)
        r.push_back(genRands(sample_per_bw, ebw, rng));
    }

    return r;
  }
};

template <typename D> class Eval {
private:
  // types
  typedef bool (*AbsOpConFn)(D, D);
  typedef D (*XferFn)(D, D);

  // members
  Jit jit;
  std::vector<XferFn> xferFns;
  std::vector<XferFn> baseFns;
  std::optional<AbsOpConFn> absOpCon;
  EnumEval<D> enumEval;

  // methods
  std::vector<D> synth_function_wrapper(const D &lhs, const D &rhs) {
    std::vector<D> r;
    std::transform(
        xferFns.begin(), xferFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return D(f(lhs.v, rhs.v)); });
    return r;
  }

  std::vector<D> base_function_wrapper(const D &lhs, const D &rhs) {
    std::vector<D> r;
    std::transform(
        baseFns.begin(), baseFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return D(f(lhs.v, rhs.v)); });
    return r;
  }

public:
  Eval(Jit _jit, const std::vector<std::string> synthFnNames,
       const std::vector<std::string> baseFnNames)
      : jit(std::move(_jit)), enumEval(nullptr, nullptr) {
    std::transform(
        synthFnNames.begin(), synthFnNames.end(), std::back_inserter(xferFns),
        [this](const std::string &x) { return jit.getFn<XferFn>(x); });

    std::transform(
        baseFnNames.begin(), baseFnNames.end(), std::back_inserter(baseFns),
        [this](const std::string &x) { return jit.getFn<XferFn>(x); });

    absOpCon = jit.getOptFn<AbsOpConFn>("abs_op_constraint");
    ConcOpFn concOpFn = jit.getFn<ConcOpFn>("concrete_op");
    std::optional<OpConFn> opConFn = jit.getOptFn<OpConFn>("op_constraint");
    enumEval = EnumEval<D>(concOpFn, opConFn);
  }

  void evalSingle(const D &lhs, const D &rhs, const D &best, Results &r) {
    // skip this pair if absOpCon returns false
    if (absOpCon && !absOpCon.value()(lhs, rhs))
      return;

    // skip the pair if there are no concrete values in the result
    if (best.isBottom())
      return;

    std::vector<D> synth_results(synth_function_wrapper(lhs, rhs));
    std::vector<D> ref_results(base_function_wrapper(lhs, rhs));
    D ref_meet = D::meetAll(ref_results, lhs.bw());
    bool solved = ref_meet == best;
    unsigned int baseDis = ref_meet.distance(best);
    for (unsigned int i = 0; i < synth_results.size(); ++i) {
      D synth_after_meet = ref_meet.meet(synth_results[i]);
      bool sound = synth_after_meet.isSuperset(best);
      bool exact = synth_after_meet == best;
      unsigned int dis = synth_after_meet.distance(best);
      unsigned int soundDis = sound ? dis : baseDis;

      r.incResult(Result(sound, dis, exact, solved, soundDis), i);
    }

    r.incCases(solved, baseDis);
  }

  const std::vector<std::tuple<D, D, D>>
  rejectSample(unsigned int bw, unsigned int samples, std::mt19937 &rng) const {
    std::vector<std::tuple<D, D, D>> r;

    for (unsigned int i = 0; i < samples; ++i) {
      while (true) {
        auto [lhs, rhs, res] = enumEval.genRand(bw, rng);

        if (absOpCon && !absOpCon.value()(lhs, rhs))
          continue;

        std::vector<D> ref_results(base_function_wrapper(lhs, rhs));
        D ref_meet = D::meetAll(ref_results, bw);

        if (ref_meet != res) {
          r.push_back({lhs, rhs, res});
          break;
        }
      }
    }

    return r;
  }

  const std::vector<Results>
  eval(const std::vector<std::vector<std::tuple<D, D, D>>> toEval) {
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
};

#endif
