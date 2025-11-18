#ifndef Eval_H
#define Eval_H

#include <algorithm>
#include <iterator>
#include <optional>
#include <random>
#include <stdexcept>
#include <string>
#include <tuple>
#include <utility>
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

template <AbstractDomain D> class EvalGenOp {

private:
  OpConFn opCon;

public:
  EvalGenOp(OpConFn _opCon) : opCon(_opCon) {}

  // define a function that take opCon as
  bool checkAbstCon(const D &lhs, const D &rhs) const {
    for (A::APInt lhs_v : lhs.toConcrete())
      for (A::APInt rhs_v : rhs.toConcrete())
        if (opCon(lhs_v, rhs_v))
          return true;

    return false;
  }
};

template <AbstractDomain D> class Eval {
private:
  // types
  typedef D (*GenFn)(D, D);

  // members
  Jit jit;
  std::vector<std::vector<GenFn>> genFns;

  // methods
  std::vector<std::vector<D>> genFnWrapper(const D &lhs, const D &rhs) const {
    std::vector<std::vector<D>> r;
    std::transform(genFns.begin(), genFns.end(), std::back_inserter(r),
                   [&lhs, &rhs](const std::vector<GenFn> &g) {
                     std::vector<D> result;
                     for (const auto &fn : g) {
                       result.push_back(D(fn(lhs, rhs)));
                     }
                     return result;
                   });
    return r;
  }

  void evalSingle(const D &lhs, const D &rhs, const ValidSet<D> &validSet,
                  Results &r) const {
    std::vector<std::vector<D>> gen_results(genFnWrapper(lhs, rhs));
    for (unsigned int i = 0; i < gen_results.size(); ++i) {
      std::vector<D> gen_value = gen_results[i];
      if (validSet.find(gen_value) != validSet.end())
        r.incResult(Result(1, 0), i);
      else
        r.incResult(Result(0, 1), i);
    }
    r.incCases();
  }

public:
  Eval(Jit _jit, const std::vector<std::vector<std::string>> synthFnNames)
      : jit(std::move(_jit)) {
    for (const auto &fnNames : synthFnNames) {
      std::vector<GenFn> fnGroup;
      for (const auto &fnName : fnNames) {
        GenFn fn = jit.getFn<GenFn>(fnName);
        fnGroup.push_back(fn);
      }
      genFns.push_back(fnGroup);
    }
  }

  const std::vector<Results> eval(const ValidSets<D> validSets) const {
    std::vector<Results> r;

    for (unsigned int i = 0; i < validSets.size(); ++i) {
      unsigned int bw = getBw(validSets[i]);
      r.push_back({static_cast<unsigned int>(validSets.size()), bw});
      const std::vector<D> fullLattice = D::enumVals(bw);

      for (const D &lhs : fullLattice)
        for (const D &rhs : fullLattice) {
          evalSingle(lhs, rhs, validSets[i], r[i]);
        }
    }

    return r;
  }
};

#endif
