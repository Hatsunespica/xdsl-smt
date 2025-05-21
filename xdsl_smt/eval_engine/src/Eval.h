#ifndef Eval_H
#define Eval_H

#include <algorithm>
#include <functional>
#include <iterator>
#include <memory>
#include <optional>
#include <random>
#include <string>
#include <vector>

#include "APInt.h"
#include "Results.h"
#include "warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/Error.h>
SUPPRESS_WARNINGS_END

template <typename Domain> class EnumXfer {
private:
  // types
  typedef std::function<A::APInt(A::APInt, A::APInt)> ConcOpFn;
  typedef std::function<bool(A::APInt, A::APInt)> OpConstraintFn;

  // members
  std::unique_ptr<llvm::orc::LLJIT> jit;
  std::optional<OpConstraintFn> opCon;
  ConcOpFn concOp;
  unsigned int lbw;
  unsigned int ubw;

  // methods
  const Domain toBestAbst(const Domain &lhs, const Domain &rhs) {
    Domain res = Domain::bottom(lhs.bw());

    for (A::APInt lhs_v : lhs.toConcrete())
      for (A::APInt rhs_v : rhs.toConcrete())
        if (!opCon || opCon.value()(lhs_v, rhs_v))
          res = res.join(Domain::fromConcrete(concOp(lhs_v, rhs_v)));

    return res;
  }

public:
  EnumXfer(std::unique_ptr<llvm::orc::LLJIT> _jit, unsigned int _ubw,
           unsigned int _lbw)
      : jit(std::move(_jit)), ubw(_ubw), lbw(_lbw) {

    concOp = llvm::cantFail(jit->lookup("concrete_op"))
                 .toPtr<A::APInt(A::APInt, A::APInt)>();

    llvm::Expected<llvm::orc::ExecutorAddr> mOpCons =
        jit->lookup("op_constraint");

    opCon =
        !mOpCons
            ? std::nullopt
            : std::optional(mOpCons.get().toPtr<bool(A::APInt, A::APInt)>());

    llvm::consumeError(mOpCons.takeError());
  }

  const std::vector<std::tuple<Domain, Domain, Domain>>
  genRand(unsigned int seed, unsigned int samples, unsigned int ebw) {
    std::vector<std::tuple<Domain, Domain, Domain>> r;
    std::mt19937 rng(seed);

    for (unsigned int i = 0; i < samples; ++i) {
      Domain lhs = Domain(rng, ebw);
      Domain rhs = Domain(rng, ebw);
      Domain res = toBestAbst(lhs, rhs);
      r.push_back({lhs, rhs, res});
    }

    return r;
  }

  const std::vector<std::tuple<Domain, Domain, Domain>>
  genLattice(unsigned int ebw) {
    std::vector<std::tuple<Domain, Domain, Domain>> r;
    const std::vector<Domain> fullLattice = Domain::enumVals(ebw);

    for (Domain lhs : fullLattice)
      for (Domain rhs : fullLattice)
        r.push_back({lhs, rhs, toBestAbst(lhs, rhs)});

    return r;
  }

  const std::vector<std::vector<std::tuple<Domain, Domain, Domain>>>
  genAllBws() {
    std::vector<std::vector<std::tuple<Domain, Domain, Domain>>> r;

    for (unsigned int ebw = lbw; ebw <= ubw; ++ebw)
      r.push_back(genLattice(ebw));

    return r;
  }

  const std::vector<std::vector<std::tuple<Domain, Domain, Domain>>>
  genAllBwsRand(unsigned int seed, unsigned int samples) {
    std::vector<std::vector<std::tuple<Domain, Domain, Domain>>> r;

    for (unsigned int ebw = lbw; ebw <= std::min(ubw, 4u); ++ebw)
      r.push_back(genLattice(ebw));

    if (ubw > 4) {
      unsigned int tmplbw = std::max(5u, lbw);
      unsigned int sample_per_bw = samples / (ubw - tmplbw + 1);
      for (unsigned int ebw = tmplbw; ebw <= ubw; ++ebw)
        r.push_back(genRand(seed, sample_per_bw, ebw));
    }

    return r;
  }
};

template <typename Domain> class Eval {
private:
  // types
  typedef std::function<bool(Domain, Domain)> AbsOpConstraintFn;
  typedef Domain (*XferFn)(Domain, Domain);

  // members
  std::unique_ptr<llvm::orc::LLJIT> jit;
  std::vector<std::vector<std::tuple<Domain, Domain, Domain>>> toEval;
  std::vector<XferFn> xferFns;
  std::vector<XferFn> baseFns;
  std::optional<AbsOpConstraintFn> absOpCon;

  // methods
  std::vector<Domain> synth_function_wrapper(const Domain &lhs,
                                             const Domain &rhs) {
    std::vector<Domain> r;
    std::transform(
        xferFns.begin(), xferFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return Domain(f(lhs.v, rhs.v)); });
    return r;
  }

  std::vector<Domain> base_function_wrapper(const Domain &lhs,
                                            const Domain &rhs) {
    std::vector<Domain> r;
    std::transform(
        baseFns.begin(), baseFns.end(), std::back_inserter(r),
        [&lhs, &rhs](const XferFn &f) { return Domain(f(lhs.v, rhs.v)); });
    return r;
  }

public:
  Eval(std::unique_ptr<llvm::orc::LLJIT> jit0,
       const std::vector<std::string> synthFnNames,
       const std::vector<std::string> baseFnNames,
       const std::vector<std::vector<std::tuple<Domain, Domain, Domain>>>
           toEval_)
      : jit(std::move(jit0)), toEval(toEval_) {

    std::transform(synthFnNames.begin(), synthFnNames.end(),
                   std::back_inserter(xferFns), [this](const std::string &x) {
                     return llvm::cantFail(jit->lookup(x)).toPtr<XferFn>();
                   });

    std::transform(baseFnNames.begin(), baseFnNames.end(),
                   std::back_inserter(baseFns), [this](const std::string &x) {
                     return llvm::cantFail(jit->lookup(x)).toPtr<XferFn>();
                   });

    llvm::Expected<llvm::orc::ExecutorAddr> mAbsOpCons =
        jit->lookup("abs_op_constraint");

    absOpCon =
        !mAbsOpCons
            ? std::nullopt
            : std::optional(mAbsOpCons.get().toPtr<bool(Domain, Domain)>());

    llvm::consumeError(mAbsOpCons.takeError());
  }

  void evalSingle(const Domain &lhs, const Domain &rhs, const Domain &best,
                  Results &r) {
    // If abs_op_constraint returns false, we skip this pair
    if (absOpCon && !absOpCon.value()(lhs, rhs))
      return;

    // skip the pair if no concrete values satisfy op_constraint
    if (best.isBottom())
      return;

    std::vector<Domain> synth_kbs(synth_function_wrapper(lhs, rhs));
    std::vector<Domain> ref_kbs(base_function_wrapper(lhs, rhs));
    Domain cur_kb = Domain::meetAll(ref_kbs, lhs.bw());
    bool solved = cur_kb == best;
    unsigned int baseDis = cur_kb.distance(best);
    for (unsigned int i = 0; i < synth_kbs.size(); ++i) {
      Domain synth_after_meet = cur_kb.meet(synth_kbs[i]);
      bool sound = synth_after_meet.isSuperset(best);
      bool exact = synth_after_meet == best;
      unsigned int dis = synth_after_meet.distance(best);
      unsigned int soundDis = sound ? dis : baseDis;

      r.incResult(Result(sound, dis, exact, solved, soundDis), i);
    }

    r.incCases(solved, baseDis);
  }

  const std::vector<Results> eval() {
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
