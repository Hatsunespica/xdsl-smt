#ifndef Eval_H
#define Eval_H

#include <algorithm>
#include <functional>
#include <iterator>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "APInt.h"
#include "Results.h"
#include "warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/Error.h>
SUPPRESS_WARNINGS_END

template <typename Domain> class Eval {
private:
  // types
  typedef std::function<A::APInt(A::APInt, A::APInt)> ConcOpFn;
  typedef std::function<bool(A::APInt, A::APInt)> OpConstraintFn;
  typedef std::function<bool(Domain, Domain)> AbsOpConstraintFn;

  // members
  std::unique_ptr<llvm::orc::LLJIT> jit;
  unsigned int bw;
  std::vector<typename Domain::XferFn> xferFns;
  std::vector<typename Domain::XferFn> baseFns;
  std::optional<OpConstraintFn> opCon;
  std::optional<AbsOpConstraintFn> absOpCon;
  ConcOpFn concOp;

  // methods
  std::vector<Domain> synth_function_wrapper(const Domain &lhs,
                                             const Domain &rhs) {
    std::vector<Domain> r;
    std::transform(xferFns.begin(), xferFns.end(), std::back_inserter(r),
                   [&lhs, &rhs](const typename Domain::XferFn &f) {
                     return Domain(f(lhs.v, rhs.v));
                   });
    return r;
  }

  std::vector<Domain> base_function_wrapper(const Domain &lhs,
                                            const Domain &rhs) {
    std::vector<Domain> r;
    std::transform(baseFns.begin(), baseFns.end(), std::back_inserter(r),
                   [&lhs, &rhs](const typename Domain::XferFn &f) {
                     return Domain(f(lhs.v, rhs.v));
                   });
    return r;
  }

  const Domain toBestAbst(const Domain &lhs, const Domain &rhs, unsigned int ebw) {
    std::vector<Domain> crtVals;
    const std::vector<unsigned int> rhss = rhs.toConcrete();

    for (unsigned int lhs_v : lhs.toConcrete()) {
      for (unsigned int rhs_v : rhss) {
        if (!opCon || opCon.value()(A::APInt(ebw, lhs_v), A::APInt(ebw, rhs_v)))
          crtVals.push_back(Domain::fromConcrete(
              concOp(A::APInt(ebw, lhs_v), A::APInt(ebw, rhs_v))));
      }
    }

    return Domain::joinAll(crtVals, ebw);
  }

public:
  Eval(std::unique_ptr<llvm::orc::LLJIT> jit0,
       const std::vector<std::string> synthFnNames,
       const std::vector<std::string> baseFnNames, unsigned int bw0)
      : jit(std::move(jit0)), bw(bw0) {

    std::transform(synthFnNames.begin(), synthFnNames.end(),
                   std::back_inserter(xferFns), [this](const std::string &x) {
                     return llvm::cantFail(jit->lookup(x))
                         .toPtr<typename Domain::XferFn>();
                   });

    std::transform(baseFnNames.begin(), baseFnNames.end(),
                   std::back_inserter(baseFns), [this](const std::string &x) {
                     return llvm::cantFail(jit->lookup(x))
                         .toPtr<typename Domain::XferFn>();
                   });

    concOp = llvm::cantFail(jit->lookup("concrete_op"))
                 .toPtr<A::APInt(A::APInt, A::APInt)>();

    llvm::Expected<llvm::orc::ExecutorAddr> mOpCons =
        jit->lookup("op_constraint");

    llvm::Expected<llvm::orc::ExecutorAddr> mAbsOpCons =
        jit->lookup("abs_op_constraint");

    opCon =
        !mOpCons
            ? std::nullopt
            : std::optional(mOpCons.get().toPtr<bool(A::APInt, A::APInt)>());

    absOpCon =
        !mAbsOpCons
            ? std::nullopt
            : std::optional(mAbsOpCons.get().toPtr<bool(Domain, Domain)>());

    llvm::consumeError(mOpCons.takeError());
    llvm::consumeError(mAbsOpCons.takeError());
  }

  const std::vector<Results> eval() {
    std::vector<Results> r(bw, static_cast<unsigned int>(xferFns.size()));

    for (unsigned int ebw = 1; ebw <= bw; ++ebw) {
      const std::vector<Domain> fullLattice = Domain::enumVals(ebw);
      for (Domain lhs : fullLattice) {
        for (Domain rhs : fullLattice) {

          // If abs_op_constraint returns false, we skip this pair
          if (absOpCon && !absOpCon.value()(lhs, rhs))
            continue;

          Domain best_abstract_res = toBestAbst(lhs, rhs, ebw);

          // skip the pair if no concrete values satisfy op_constraint
          if (best_abstract_res.isBottom())
            continue;

          std::vector<Domain> synth_kbs(synth_function_wrapper(lhs, rhs));
          std::vector<Domain> ref_kbs(base_function_wrapper(lhs, rhs));
          Domain cur_kb = Domain::meetAll(ref_kbs, ebw);
          bool solved = cur_kb == best_abstract_res;
          unsigned int baseDis = cur_kb.distance(best_abstract_res);
          for (unsigned int i = 0; i < synth_kbs.size(); ++i) {
            Domain synth_after_meet = cur_kb.meet(synth_kbs[i]);
            bool sound = synth_after_meet.isSuperset(best_abstract_res);
            bool exact = synth_after_meet == best_abstract_res;
            unsigned int dis = synth_after_meet.distance(best_abstract_res);
            unsigned int soundDis = sound ? dis : baseDis;

            r[ebw - 1].incResult(Result(sound, dis, exact, solved, soundDis),
                                 i);
          }

          r[ebw - 1].incCases(solved, baseDis);
        }
      }
    }

    return r;
  }
};

#endif
