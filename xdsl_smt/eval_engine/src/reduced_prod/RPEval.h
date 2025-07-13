#ifndef RPEval_H
#define RPEval_H

#include <algorithm>
// #include <iostream>
#include <optional>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include "../APInt.h"
#include "../AbstVal.h"
#include "../Eval.h"
#include "../Results.h"
#include "../jit.h"
#include "../utils.cpp"
#include "../warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include "llvm/IR/ConstantRange.h"
#include "llvm/Support/KnownBits.h"
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/Error.h>
SUPPRESS_WARNINGS_END

struct Product {
  KnownBits kb;
  UConstRange ucr;
  SConstRange scr;

  bool operator<(const Product &rhs) const {
    return std::tuple(kb.v[0].getZExtValue(), kb.v[1].getZExtValue(),
                      ucr.v[0].getZExtValue(), ucr.v[1].getZExtValue(),
                      scr.v[0].getZExtValue(), scr.v[1].getZExtValue()) <
           std::tuple(rhs.kb.v[0].getZExtValue(), rhs.kb.v[1].getZExtValue(),
                      rhs.ucr.v[0].getZExtValue(), rhs.ucr.v[1].getZExtValue(),
                      rhs.scr.v[0].getZExtValue(), rhs.scr.v[1].getZExtValue());
  }

  bool operator==(const Product &rhs) const {
    return kb == rhs.kb && ucr == rhs.ucr && scr == rhs.scr;
  }
};

inline const Product bruteReduce(const Product &x) {
  std::vector<A::APInt> cncVals;
  std::vector<A::APInt> kbVals = x.kb.toConcrete();
  std::vector<A::APInt> ucrVals = x.ucr.toConcrete();
  std::vector<A::APInt> scrVals = x.scr.toConcrete();

  auto cmp = [](const A::APInt &lhs, const A::APInt &rhs) {
    return lhs.ult(rhs);
  };

  std::sort(kbVals.begin(), kbVals.end(), cmp);
  std::sort(ucrVals.begin(), ucrVals.end(), cmp);
  std::sort(scrVals.begin(), scrVals.end(), cmp);

  std::vector<A::APInt> kb_and_ucr;
  std::set_intersection(kbVals.begin(), kbVals.end(), ucrVals.begin(),
                        ucrVals.end(), std::back_inserter(kb_and_ucr), cmp);

  std::set_intersection(kb_and_ucr.begin(), kb_and_ucr.end(), scrVals.begin(),
                        scrVals.end(), std::back_inserter(cncVals), cmp);

  KnownBits kbRes = KnownBits::bottom(x.kb.bw());
  UConstRange ucrRes = UConstRange::bottom(x.kb.bw());
  SConstRange scrRes = SConstRange::bottom(x.kb.bw());

  for (const A::APInt &x_ : cncVals) {
    kbRes = kbRes.join(KnownBits::fromConcrete(x_));
    ucrRes = ucrRes.join(UConstRange::fromConcrete(x_));
    scrRes = scrRes.join(SConstRange::fromConcrete(x_));
  }

  return Product({kbRes, ucrRes, scrRes});
}

inline const std::pair<UConstRange, SConstRange>
reduceCr(const UConstRange &ucr, const SConstRange &scr) {
  UConstRange newUcr = ucr;
  SConstRange newScr = scr;

  bool overlap = false;
  if (scr.v[0].ule(scr.v[1])) {
    overlap = !(scr.v[0].ugt(ucr.v[1]) || scr.v[1].ult(ucr.v[0]));
  } else {
    bool overlap_high = !(scr.v[0].ugt(ucr.v[1]));
    bool overlap_low = !(scr.v[1].ult(ucr.v[0]));
    overlap = overlap_high || overlap_low;
  }

  if (!overlap)
    return {UConstRange::bottom(ucr.bw()), SConstRange::bottom(scr.bw())};

  if (ucr.v[0].isNegative() == ucr.v[1].isNegative())
    newScr = newScr.meet(SConstRange({ucr.v[0], ucr.v[1]}));

  if (scr.v[0].isNegative() == scr.v[1].isNegative())
    newUcr = newUcr.meet(UConstRange({scr.v[0], scr.v[1]}));

  if ((ucr.v[0].isNegative() != ucr.v[1].isNegative()) &&
      (scr.v[0].isNegative() != scr.v[1].isNegative())) {
    if (newUcr.v[1].uge(newScr.v[0]) && newUcr.v[0].ugt(newScr.v[1])) {
      newScr = newScr.meet(SConstRange({scr.v[0], ucr.v[1]}));
      newUcr = newUcr.meet(UConstRange({scr.v[0], ucr.v[1]}));
    }

    if (newUcr.v[0].ule(newScr.v[1]) && newUcr.v[1].ult(newScr.v[0])) {
      newScr = newScr.meet(SConstRange({ucr.v[0], scr.v[1]}));
      newUcr = newUcr.meet(UConstRange({ucr.v[0], scr.v[1]}));
    }
  }

  return {newUcr, newScr};
}

inline const std::pair<UConstRange, SConstRange> kbToCr(const Product &x) {
  A::APInt kbMin = x.kb.v[1];
  A::APInt kbMax = ~x.kb.v[0];

  UConstRange ucr = x.ucr;
  SConstRange scr = x.scr;
  unsigned int bw = x.kb.bw();

  //////////////////////////////////////
  // UCR rules
  //////////////////////////////////////

  // Known zero but min ucr has a one
  for (unsigned int i = bw - 1;; --i) {
    for (unsigned int j = i;; --j) {
      if (x.kb.v[0][j] && ucr.v[0][j]) {
        ucr.v[0] += 1 << j;
        ucr.v[0] &= ~(~kbMin & A::APInt::getLowBitsSet(x.kb.bw(), j));
        break;
      }
      if (j == 0)
        break;
    }
    if (i == 0)
      break;
  }

  // Known one but min ucr has a zero
  for (unsigned int i = bw - 1;; --i) {
    for (unsigned int j = i;; --j) {
      if (x.kb.v[1][j] && !ucr.v[0][j]) {
        ucr.v[0] += 1 << j;
        ucr.v[0] &= ~(~kbMin & A::APInt::getLowBitsSet(x.kb.bw(), j));
        break;
      }
      if (j == 0)
        break;
    }
    if (i == 0)
      break;
  }

  // Known zero but max ucr has a one
  for (unsigned int i = 0; i < bw; ++i) {
    for (unsigned int j = i; j < bw; ++j) {
      if (x.kb.v[0][j] && ucr.v[1][j]) {
        ucr.v[1] -= 1 << j;
        ucr.v[1] |= kbMax & A::APInt::getLowBitsSet(x.kb.bw(), j);
        break;
      }
    }
  }

  // Known one but max ucr has a zero
  for (unsigned int i = 0; i < bw; ++i) {
    for (unsigned int j = i; j < bw; ++j) {
      if (x.kb.v[1][j] && !ucr.v[1][j]) {
        ucr.v[1] -= 1 << j;
        ucr.v[1] |= kbMax & A::APInt::getLowBitsSet(x.kb.bw(), j);
        break;
      }
    }
  }

  ////////////////////
  // SCR rules
  ////////////////////

  // Known zero but min scr has a one
  for (unsigned int i = bw - 1;; --i) {
    for (unsigned int j = i;; --j) {
      if (x.kb.v[0][j] && scr.v[0][j]) {
        scr.v[0] += 1 << j;
        scr.v[0] &= ~(~kbMin & A::APInt::getLowBitsSet(x.kb.bw(), j));
        break;
      }
      if (j == 0)
        break;
    }
    if (i == 0)
      break;
  }

  // Known one but min scr has a zero
  for (unsigned int i = bw - 1;; --i) {
    for (unsigned int j = i;; --j) {
      if (x.kb.v[1][j] && !scr.v[0][j]) {
        scr.v[0] += 1 << j;
        scr.v[0] &= ~(~kbMin & A::APInt::getLowBitsSet(x.kb.bw(), j));
        break;
      }
      if (j == 0)
        break;
    }
    if (i == 0)
      break;
  }

  // Known zero but max scr has a one
  for (unsigned int i = 0; i < bw; ++i) {
    for (unsigned int j = i; j < bw; ++j) {
      if (x.kb.v[0][j] && scr.v[1][j]) {
        scr.v[1] -= 1 << j;
        scr.v[1] |= kbMax & A::APInt::getLowBitsSet(x.kb.bw(), j);
        break;
      }
    }
  }

  // Known one but max scr has a zero
  for (unsigned int i = 0; i < bw; ++i) {
    for (unsigned int j = i; j < bw; ++j) {
      if (x.kb.v[1][j] && !scr.v[1][j]) {
        scr.v[1] -= 1 << j;
        scr.v[1] |= kbMax & A::APInt::getLowBitsSet(x.kb.bw(), j);
        break;
      }
    }
  }

  ucr = ucr.meet(UConstRange({kbMin, kbMax}));

  if (!x.kb.v[0].isSignBitSet() && !x.kb.v[1].isSignBitSet()) {
    kbMin.setSignBit();
    kbMax.clearSignBit();
  }

  scr = scr.meet(SConstRange({kbMin, kbMax}));

  return reduceCr(ucr, scr);
}

inline const KnownBits crToKb(const UConstRange &ucr, const SConstRange &scr) {
  if (ucr.v[0].eq(scr.v[1]) && ucr.v[1].eq(scr.v[0]))
    return {KnownBits::fromConcrete(ucr.v[0]).join(
        KnownBits::fromConcrete(ucr.v[1]))};

  if ((ucr.v[0].isNegative() != ucr.v[1].isNegative()) &&
      (scr.v[0].isNegative() != scr.v[1].isNegative())) {
    KnownBits lowKb = KnownBits::fromConcrete(ucr.v[0]);
    if (ucr.v[0] != scr.v[1]) {
      unsigned int diffBit =
          ucr.bw() - ((ucr.v[0] ^ scr.v[1]).countl_zero() + 1);
      lowKb.v[0].clearLowBits(diffBit + 1);
      lowKb.v[1].clearLowBits(diffBit + 1);
    }

    KnownBits highKb = KnownBits::fromConcrete(scr.v[0]);
    if (scr.v[0] != ucr.v[1]) {
      unsigned int diffBit =
          scr.bw() - ((scr.v[0] ^ ucr.v[1]).countl_zero() + 1);
      highKb.v[0].clearLowBits(diffBit + 1);
      highKb.v[1].clearLowBits(diffBit + 1);
    }

    return lowKb.join(highKb);
  }

  KnownBits ucrKb = KnownBits::fromConcrete(ucr.v[0]);
  if (ucr.v[0] != ucr.v[1]) {
    unsigned int diffBit = ucr.bw() - ((ucr.v[0] ^ ucr.v[1]).countl_zero() + 1);
    ucrKb.v[0].clearLowBits(diffBit + 1);
    ucrKb.v[1].clearLowBits(diffBit + 1);
  }

  KnownBits scrKb = KnownBits::fromConcrete(scr.v[0]);
  if (scr.v[0] != scr.v[1]) {
    unsigned int diffBit = scr.bw() - ((scr.v[0] ^ scr.v[1]).countl_zero() + 1);
    scrKb.v[0].clearLowBits(diffBit + 1);
    scrKb.v[1].clearLowBits(diffBit + 1);
  }

  return ucrKb.meet(scrKb);
}

inline const Product reduceOneStep(const Product &x) {
  auto [newUcr, newScr] = reduceCr(x.ucr, x.scr);

  KnownBits newKb = x.kb.meet(crToKb(newUcr, newScr));

  auto [newNewUcr, newNewScr] = kbToCr({newKb, newUcr, newScr});
  newNewUcr = newNewUcr.meet(newUcr);
  newNewScr = newNewScr.meet(newScr);

  if (newNewUcr.isBottom() || newNewScr.isBottom() || newKb.isBottom())
    return Product({KnownBits::bottom(x.kb.bw()),
                    UConstRange::bottom(x.kb.bw()),
                    SConstRange::bottom(x.kb.bw())});

  return Product({newKb, newNewUcr, newNewScr});
}

inline const Product reduce(const Product &x) {
  Product oldProd = x;
  Product newProd = reduceOneStep(oldProd);
  while (oldProd != newProd) {
    oldProd = newProd;
    newProd = reduceOneStep(oldProd);
  }

  return newProd;
}

unsigned int inline getBw(
    const std::vector<std::tuple<Product, Product, Product>> &toEval) {
  return std::get<0>(toEval[0]).kb.bw();
}

inline llvm::KnownBits makeLlvmKb(const KnownBits &x) {
  llvm::KnownBits llvm = llvm::KnownBits(x.bw());
  llvm.Zero = x.v[0].getZExtValue();
  llvm.One = x.v[1].getZExtValue();
  return llvm;
}

inline const KnownBits kbXferWrapper(const KnownBits &lhs, const KnownBits &rhs,
                                     const XferFn<llvm::KnownBits> &fn) {
  llvm::KnownBits x = fn(makeLlvmKb(lhs), makeLlvmKb(rhs));
  return KnownBits({A::APInt(lhs.bw(), x.Zero.getZExtValue()),
                    A::APInt(lhs.bw(), x.One.getZExtValue())});
}

inline llvm::ConstantRange make_llvm_cr(const UConstRange &ucr,
                                        const SConstRange &scr) {
  if (ucr.isTop() && scr.isTop())
    return llvm::ConstantRange::getFull(ucr.bw());
  if (ucr.isBottom() || scr.isBottom())
    return llvm::ConstantRange::getEmpty(ucr.bw());

  if (ucr.isTop()) {
    return llvm::ConstantRange(llvm::APInt(ucr.bw(), scr.v[1].getZExtValue()),
                               llvm::APInt(ucr.bw(), scr.v[0].getZExtValue()) +
                                   1);
  }

  return llvm::ConstantRange(llvm::APInt(ucr.bw(), ucr.v[0].getZExtValue()),
                             llvm::APInt(ucr.bw(), ucr.v[1].getZExtValue()) +
                                 1);
}

inline const std::pair<UConstRange, SConstRange>
cr_xfer_wrapper(const std::pair<UConstRange, SConstRange> &lhs,
                const std::pair<UConstRange, SConstRange> &rhs,
                const XferFn<llvm::ConstantRange> &fn) {
  unsigned int bw = lhs.first.bw();
  llvm::ConstantRange x = fn(make_llvm_cr(lhs.first, lhs.second),
                             make_llvm_cr(rhs.first, rhs.second));

  if (x.isFullSet())
    return {UConstRange::top(bw), SConstRange::top(bw)};
  if (x.isEmptySet())
    return {UConstRange::bottom(bw), SConstRange::bottom(bw)};

  A::APInt lower(bw, x.getLower().getZExtValue());
  A::APInt upper(bw, x.getLower().getZExtValue() - 1);

  if (x.isWrappedSet())
    return {UConstRange::top(bw), SConstRange({upper, lower})};

  UConstRange ucr({lower, upper});

  if (lower.isNegative() == upper.isNegative())
    return {ucr, SConstRange({lower, upper})};

  return {ucr, SConstRange::top(bw)};
}

inline unsigned long
getCrDist(const std::pair<UConstRange, SConstRange> &cmp,
          const std::pair<UConstRange, SConstRange> &best) {
  if (cmp.first.isTop() && cmp.second.isTop())
    return 0;
  else if (cmp.first.isTop())
    return cmp.second.distance(best.second);
  else if (cmp.second.isTop())
    return cmp.first.distance(best.first);
  else
    return std::min(cmp.first.distance(best.first),
                    cmp.second.distance(best.second));
}

inline bool getCrExact(const std::pair<UConstRange, SConstRange> &cmp,
                       const std::pair<UConstRange, SConstRange> &best) {
  return (best.first.isTop() && best.second.isTop()) ||
         (!best.first.isTop() && cmp.first == best.first) ||
         (!best.second.isTop() && cmp.second == best.second);
}

class RPEval {
private:
  // types
  typedef KnownBits (*KbXferFn)(KnownBits, KnownBits);
  typedef UConstRange (*UcrXferFn)(UConstRange, UConstRange);
  typedef SConstRange (*ScrXferFn)(SConstRange, SConstRange);

  // members
  Jit jit;
  KbXferFn kbXfer;
  UcrXferFn ucrXfer;
  ScrXferFn scrXfer;

  EvalAbstOp<KnownBits> kbEvalAbstOp;
  EvalAbstOp<UConstRange> ucrEvalAbstOp;
  EvalAbstOp<SConstRange> scrEvalAbstOp;

public:
  RPEval(Jit _jit, const std::string &kbFnName, const std::string &ucrFnName,
         const std::string &scrFnName)
      : jit(std::move(_jit)), kbXfer(jit.getFn<KbXferFn>(kbFnName)),
        ucrXfer(jit.getFn<UcrXferFn>(ucrFnName)),
        scrXfer(jit.getFn<ScrXferFn>(scrFnName)),
        kbEvalAbstOp(jit.getFn<ConcOpFn>("concrete_op"),
                     jit.getOptFn<OpConFn>("op_constraint")),
        ucrEvalAbstOp(jit.getFn<ConcOpFn>("concrete_op"),
                      jit.getOptFn<OpConFn>("op_constraint")),
        scrEvalAbstOp(jit.getFn<ConcOpFn>("concrete_op"),
                      jit.getOptFn<OpConFn>("op_constraint")) {}

  const std::vector<Results> evalFinal(
      const std::vector<std::vector<std::tuple<Product, Product, Product>>>
          &toEval,
      const std::optional<LLVMXferFn<llvm::KnownBits>> &llvmKbXfer) const {
    std::vector<Results> r;

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      unsigned int bw = getBw(toEval[i]);
      r.push_back({6, bw});

      KnownBits kbTop = KnownBits::top(bw);

      for (unsigned int j = 0; j < toEval[i].size(); ++j) {
        auto [lhs, rhs, best] = toEval[i][j];

        const KnownBits kbBest = best.kb;
        const UConstRange ucrBest = best.ucr;
        const SConstRange scrBest = best.scr;

        bool kbTopExact = kbTop == kbBest;
        unsigned long kbTopDis = kbTop.distance(kbBest);

        KnownBits kbSynth = kbXfer(lhs.kb, rhs.kb);
        bool kbSynthExact = kbSynth == kbBest;
        unsigned long kbSynthDis = kbSynth.distance(kbBest);

        UConstRange ucrSynth = ucrXfer(lhs.ucr, rhs.ucr);
        SConstRange scrSynth = scrXfer(lhs.scr, rhs.scr);

        const Product synthReduced = reduce({kbSynth, ucrSynth, scrSynth});
        // if (synthReduced.kb.isBottom() && !kbBest.isBottom() && !kbSynth.isBottom()) {
        //   std::cerr << "uh oh\n";
        //   exit(10);
        // }
        bool kbReducedSynExact = synthReduced.kb == kbBest;
        unsigned long kbReducedSynDis = synthReduced.kb.distance(kbBest);

        bool kbLlvmExact = false;
        unsigned long kbLlvmDis = 0;
        bool kbMeetExact = false;
        unsigned long kbMeetDis = 0;
        bool kbMeetRedExact = false;
        unsigned long kbMeetRedDis = 0;
        if (llvmKbXfer) {
          KnownBits llvmKbRes =
              kbXferWrapper(lhs.kb, rhs.kb, llvmKbXfer.value());
          kbLlvmExact = llvmKbRes == kbBest;
          kbLlvmDis = llvmKbRes.distance(kbBest);

          KnownBits kbMeet = llvmKbRes.meet(kbSynth);
          kbMeetExact = kbMeet == kbBest;
          kbMeetDis = kbMeet.distance(kbBest);

          KnownBits kbMeetReduced = llvmKbRes.meet(synthReduced.kb);
          kbMeetRedExact = kbMeetReduced == kbBest;
          kbMeetRedDis = kbMeetReduced.distance(kbBest);
        }

        r[i].incResult(Result(0, kbTopDis, kbTopExact, 0, 0), 0);
        r[i].incResult(Result(0, kbSynthDis, kbSynthExact, 0, 0), 1);
        r[i].incResult(Result(0, kbLlvmDis, kbLlvmExact, 0, 0), 2);
        r[i].incResult(Result(0, kbMeetDis, kbMeetExact, 0, 0), 3);
        r[i].incResult(Result(0, kbReducedSynDis, kbReducedSynExact, 0, 0), 4);
        r[i].incResult(Result(0, kbMeetRedDis, kbMeetRedExact, 0, 0), 5);
        r[i].incCases(0, 0);
      }
    }

    return r;
  }

  const std::vector<std::vector<std::tuple<Product, Product, Product>>>
  genLows(const std::vector<unsigned int> &bws) const {
    std::vector<std::vector<std::tuple<Product, Product, Product>>> r;
    std::transform(bws.begin(), bws.end(), std::back_inserter(r),
                   [this](unsigned int bw) { return getFullLattice(bw); });

    return r;
  }
  const std::vector<std::vector<std::tuple<Product, Product, Product>>>
  genMids(const std::vector<std::pair<unsigned int, unsigned int>> &bws,
          std::mt19937 &rng) const {

    std::vector<std::vector<std::tuple<Product, Product, Product>>> r;
    for (auto tup : bws) {
      r.push_back(sampleLattice(tup.first, tup.second, rng, -1));
    }

    return r;
  }

  const std::vector<std::vector<std::tuple<Product, Product, Product>>>
  genHighs(
      const std::vector<std::tuple<unsigned int, unsigned int, unsigned int>>
          &bws,
      std::mt19937 &rng) const {
    std::vector<std::vector<std::tuple<Product, Product, Product>>> r;
    for (auto tup : bws) {
      unsigned int bw = std::get<0>(tup);
      unsigned int latticeSamples = std::get<1>(tup);
      int numConcSamples = static_cast<int>(std::get<2>(tup));

      r.push_back(sampleLattice(bw, latticeSamples, rng, numConcSamples));
    }

    return r;
  }

  const std::vector<std::tuple<Product, Product, Product>>
  getFullLattice(unsigned int bw) const {
    std::vector<std::tuple<Product, Product, Product>> r;
    const std::vector<Product> fullLattice = enumVals(bw);

    for (const Product &lhs : fullLattice)
      for (const Product &rhs : fullLattice) {
        const KnownBits kbBest = kbEvalAbstOp.toBestAbst(lhs.kb, rhs.kb);
        const UConstRange ucrBest = ucrEvalAbstOp.toBestAbst(lhs.ucr, rhs.ucr);
        const SConstRange scrBest = scrEvalAbstOp.toBestAbst(lhs.scr, rhs.scr);
        if (!kbBest.isBottom() && !ucrBest.isBottom() && !scrBest.isBottom())
          r.push_back({lhs, rhs, {kbBest, ucrBest, scrBest}});
      }

    return r;
  }

  const std::vector<std::tuple<Product, Product, Product>>
  sampleLattice(unsigned int bw, unsigned int samples, std::mt19937 &rng,
                int concSamples) const {
    std::vector<std::tuple<Product, Product, Product>> bwLat;

    for (unsigned int j = 0; j < samples; ++j) {
      // sample lhs
      KnownBits lhsKb = KnownBits::bottom(bw);
      UConstRange lhsUcr = UConstRange::bottom(bw);
      SConstRange lhsScr = SConstRange::bottom(bw);
      while (reduce({lhsKb, lhsUcr, lhsScr}).kb.isBottom()) {
        lhsKb = KnownBits::rand(rng, bw);
        lhsUcr = UConstRange::rand(rng, bw);
        lhsScr = SConstRange::rand(rng, bw);
      }

      // sample rhs
      KnownBits rhsKb = KnownBits::bottom(bw);
      UConstRange rhsUcr = UConstRange::bottom(bw);
      SConstRange rhsScr = SConstRange::bottom(bw);
      while (reduce({rhsKb, rhsUcr, rhsScr}).kb.isBottom()) {
        rhsKb = KnownBits::rand(rng, bw);
        rhsUcr = UConstRange::rand(rng, bw);
        rhsScr = SConstRange::rand(rng, bw);
      }

      // Calc Res
      const Product lhsRed = reduce({lhsKb, lhsUcr, lhsScr});
      const Product rhsRed = reduce({rhsKb, rhsUcr, rhsScr});

      KnownBits resKb = KnownBits::bottom(bw);
      if (concSamples == -1) {
        resKb = kbEvalAbstOp.toBestAbst(lhsRed.kb, rhsRed.kb);
      } else {
        for (int i = 0; i < concSamples; ++i) {
          const A::APInt lhsConc = lhsRed.kb.getRandConcrete(rng);
          const A::APInt rhsConc = rhsRed.kb.getRandConcrete(rng);
          if (!kbEvalAbstOp.opCon ||
              kbEvalAbstOp.opCon.value()(lhsConc, rhsConc))
            resKb = resKb.join(
                KnownBits::fromConcrete(kbEvalAbstOp.concOp(lhsConc, rhsConc)));
        }
      }

      UConstRange resUcr = UConstRange::bottom(bw);
      if (concSamples == -1) {
        resUcr = ucrEvalAbstOp.toBestAbst(lhsRed.ucr, rhsRed.ucr);
      } else {
        for (int i = 0; i < concSamples; ++i) {
          const A::APInt lhsConc = lhsRed.ucr.getRandConcrete(rng);
          const A::APInt rhsConc = rhsRed.ucr.getRandConcrete(rng);
          if (!ucrEvalAbstOp.opCon ||
              ucrEvalAbstOp.opCon.value()(lhsConc, rhsConc))
            resUcr = resUcr.join(UConstRange::fromConcrete(
                ucrEvalAbstOp.concOp(lhsConc, rhsConc)));
        }
      }

      SConstRange resScr = SConstRange::bottom(bw);
      if (concSamples == -1) {
        resScr = scrEvalAbstOp.toBestAbst(lhsRed.scr, rhsRed.scr);
      } else {
        for (int i = 0; i < concSamples; ++i) {
          const A::APInt lhsConc = lhsRed.scr.getRandConcrete(rng);
          const A::APInt rhsConc = rhsRed.scr.getRandConcrete(rng);
          if (!scrEvalAbstOp.opCon ||
              scrEvalAbstOp.opCon.value()(lhsConc, rhsConc))
            resScr = resScr.join(SConstRange::fromConcrete(
                scrEvalAbstOp.concOp(lhsConc, rhsConc)));
        }
      }

      bwLat.push_back({
          reduce({lhsKb, lhsUcr, lhsScr}),
          reduce({rhsKb, rhsUcr, rhsScr}),
          reduce({resKb, resUcr, resScr}),
      });
    }

    return bwLat;
  }

  const std::vector<Product> enumVals(unsigned int bw) const {
    const std::vector<KnownBits> kbLattice = KnownBits::enumVals(bw);
    const std::vector<UConstRange> ucrLattice = UConstRange::enumVals(bw);
    const std::vector<SConstRange> scrLattice = SConstRange::enumVals(bw);
    std::vector<Product> r;

    for (const KnownBits &kbVal : kbLattice) {
      for (const UConstRange &ucrVal : ucrLattice) {
        for (const SConstRange &scrVal : scrLattice) {
          const Product reducedVal = reduce({kbVal, ucrVal, scrVal});
          if (!reducedVal.kb.isBottom() && !reducedVal.ucr.isBottom() &&
              !reducedVal.scr.isBottom())
            r.push_back(reducedVal);
        }
      }
    }

    std::sort(r.begin(), r.end());
    r.erase(std::unique(r.begin(), r.end()), r.end());

    return r;
  }
};

#endif
