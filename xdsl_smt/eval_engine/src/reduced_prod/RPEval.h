#ifndef RPEval_H
#define RPEval_H

#include <algorithm>
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

inline const std::pair<UConstRange, SConstRange>
reduceCr(const UConstRange &ucr, const SConstRange &scr) {
  UConstRange newUcr = ucr;
  SConstRange newScr = scr;

  if (!ucr.v[0].sgt(ucr.v[1])) {
    if (ucr.v[0].isNegative() && ucr.v[1].isNegative())
      newScr = newScr.meet(SConstRange({ucr.v[1], ucr.v[0]}));
    else
      newScr = newScr.meet(SConstRange({ucr.v[0], ucr.v[1]}));
  }

  if (!scr.v[0].ugt(scr.v[1]))
    newUcr = newUcr.meet(UConstRange({scr.v[0], scr.v[1]}));

  return {newUcr, newScr};
}

inline const Product reduce(const Product &x) {
  auto [newUcr, newScr] = reduceCr(x.ucr, x.scr);
  KnownBits newKb = x.kb;

  A::APInt min = newUcr.isTop() ? newScr.v[0] : newUcr.v[0];
  A::APInt max = newUcr.isTop() ? newScr.v[1] : newUcr.v[1];

  if (min != max) {
    if (min.ugt(max)) {
      A::APInt tmp = max;
      max = min;
      min = tmp;
    }

    unsigned int diffBit = min.getBitWidth() - ((min ^ max).countl_zero() + 1);
    A::APInt newKbZero = min;
    A::APInt newKbOnes = min;
    newKbZero.clearLowBits(diffBit + 1);
    newKbOnes.clearLowBits(diffBit + 1);

    newKb = newKb.meet(KnownBits({newKbZero, newKbOnes}));
  }

  A::APInt aMin = newKb.v[1];
  A::APInt aMax = ~newKb.v[0];
  newUcr = newUcr.meet(UConstRange({aMin, aMax}));

  if (newKb.v[0].isSignBitSet()) {
    newScr = newScr.meet(SConstRange({aMin, aMax}));
  }
  if (newKb.v[1].isSignBitSet()) {
    newScr = newScr.meet(SConstRange({aMax, aMin}));
  } else {
    aMin.setSignBit();
    aMax.clearSignBit();
    newScr = newScr.meet(SConstRange({aMin, aMax}));
  }

  return Product({newKb, newUcr, newScr});
}

inline bool isBottom(const Product &x) {
  return x.kb.isBottom() || x.ucr.isBottom() || x.scr.isBottom();
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
      const std::optional<LLVMXferFn<llvm::KnownBits>> &llvmKbXfer,
      const std::optional<LLVMXferFn<llvm::ConstantRange>> &llvmCrXfer) const {
    std::vector<Results> r;

    for (unsigned int i = 0; i < toEval.size(); ++i) {
      unsigned int bw = getBw(toEval[i]);
      r.push_back({12, bw});

      KnownBits kbTop = KnownBits::top(bw);
      UConstRange ucrTop = UConstRange::top(bw);
      SConstRange scrTop = SConstRange::top(bw);

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

        bool crTopExact = getCrExact({ucrTop, scrTop}, {ucrBest, scrBest});
        unsigned long crTopDis =
            getCrDist({ucrTop, scrTop}, {ucrBest, scrBest});

        bool crSynthExact =
            getCrExact({ucrSynth, scrSynth}, {ucrBest, scrBest});
        unsigned long crSynthDis =
            getCrDist({ucrSynth, scrSynth}, {ucrBest, scrBest});

        const Product reduced = reduce({kbSynth, ucrSynth, scrSynth});
        bool kbReducedSynExact = reduced.kb == kbBest;
        unsigned long kbReducedSynDis = reduced.kb.distance(kbBest);

        bool crRedSynExact =
            getCrExact({reduced.ucr, reduced.scr}, {ucrBest, scrBest});
        unsigned long crRedSynDis =
            getCrDist({reduced.ucr, reduced.scr}, {ucrBest, scrBest});

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

          KnownBits kbMeetReduced = llvmKbRes.meet(reduced.kb);
          kbMeetRedExact = kbMeetReduced == kbBest;
          kbMeetRedDis = kbMeetReduced.distance(kbBest);
        }

        bool crLlvmExact = false;
        unsigned long crLlvmDis = 0;
        bool crLlvmMeetExact = false;
        unsigned long crLlvmMeetDis = 0;
        bool crLlvmMRedExact = false;
        unsigned long crLlvmMRedDis = 0;
        if (llvmCrXfer) {
          auto [llvmUcrRes, llvmScrRes] = cr_xfer_wrapper(
              {lhs.ucr, lhs.scr}, {rhs.ucr, rhs.scr}, llvmCrXfer.value());

          crLlvmExact =
              getCrExact({llvmUcrRes, llvmScrRes}, {ucrBest, scrBest});
          crLlvmDis = getCrDist({llvmUcrRes, llvmScrRes}, {ucrBest, scrBest});

          UConstRange ucrMeet = llvmUcrRes.meet(ucrSynth);
          SConstRange scrMeet = llvmScrRes.meet(scrSynth);

          crLlvmMeetExact = getCrExact({ucrMeet, scrMeet}, {ucrBest, scrBest});
          crLlvmMeetDis = getCrDist({ucrMeet, scrMeet}, {ucrBest, scrBest});

          UConstRange ucrMeetRed = llvmUcrRes.meet(reduced.ucr);
          SConstRange scrMeetRed = llvmScrRes.meet(reduced.scr);

          crLlvmMRedExact =
              getCrExact({ucrMeetRed, scrMeetRed}, {ucrBest, scrBest});
          crLlvmMRedDis =
              getCrDist({ucrMeetRed, scrMeetRed}, {ucrBest, scrBest});
        }

        r[i].incResult(Result(0, kbTopDis, kbTopExact, 0, 0), 0);
        r[i].incResult(Result(0, kbSynthDis, kbSynthExact, 0, 0), 1);
        r[i].incResult(Result(0, kbLlvmDis, kbLlvmExact, 0, 0), 2);
        r[i].incResult(Result(0, kbMeetDis, kbMeetExact, 0, 0), 3);
        r[i].incResult(Result(0, kbReducedSynDis, kbReducedSynExact, 0, 0), 4);
        r[i].incResult(Result(0, kbMeetRedDis, kbMeetRedExact, 0, 0), 5);
        r[i].incResult(Result(0, crTopDis, crTopExact, 0, 0), 6);
        r[i].incResult(Result(0, crSynthDis, crSynthExact, 0, 0), 7);
        r[i].incResult(Result(0, crLlvmExact, crLlvmDis, 0, 0), 8);
        r[i].incResult(Result(0, crLlvmMeetExact, crLlvmMeetDis, 0, 0), 9);
        r[i].incResult(Result(0, crRedSynDis, crRedSynExact, 0, 0), 10);
        r[i].incResult(Result(0, crLlvmMRedExact, crLlvmMRedDis, 0, 0), 11);
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
    std::transform(bws.begin(), bws.end(), std::back_inserter(r),
                   [this, &rng](std::pair<unsigned int, unsigned int> bw) {
                     return sampleLattice(bw.first, bw.second, rng, -1);
                   });

    return r;
  }

  const std::vector<std::vector<std::tuple<Product, Product, Product>>>
  genHighs(
      const std::vector<std::tuple<unsigned int, unsigned int, unsigned int>>
          &bws,
      std::mt19937 &rng) const {

    std::vector<std::vector<std::tuple<Product, Product, Product>>> r;
    std::transform(
        bws.begin(), bws.end(), std::back_inserter(r),
        [this, &rng](std::tuple<unsigned int, unsigned int, unsigned int> bw) {
          return sampleLattice(std::get<0>(bw), std::get<1>(bw), rng,
                               static_cast<int>(std::get<2>(bw)));
        });

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

  // TODO this is kinda weird bc of how genRand works
  // maybe redo if results are weird or John doesn't like it
  const std::vector<std::tuple<Product, Product, Product>>
  sampleLattice(unsigned int bw, unsigned int samples, std::mt19937 &rng,
                int concSamples) const {
    std::uniform_int_distribution<long> dist(0, 1);

    std::vector<std::tuple<Product, Product, Product>> r;
    for (unsigned int i = 0; i < samples; ++i) {
      if (dist(rng) == 0) {
        std::tuple<KnownBits, KnownBits, KnownBits> randKb =
            kbEvalAbstOp.genRand(bw, rng, concSamples);
        const KnownBits kbLhs = std::get<0>(randKb);
        const KnownBits kbRhs = std::get<1>(randKb);
        const KnownBits kbBest = std::get<2>(randKb);

        const Product prodLhs =
            reduce({kbLhs, UConstRange::top(bw), SConstRange::top(bw)});
        const Product prodRhs =
            reduce({kbRhs, UConstRange::top(bw), SConstRange::top(bw)});
        const Product prodBest =
            reduce({kbBest, UConstRange::top(bw), SConstRange::top(bw)});

        r.push_back({prodLhs, prodRhs, prodBest});
      } else {
        if (dist(rng) == 0) {
          std::tuple<UConstRange, UConstRange, UConstRange> randUcr =
              ucrEvalAbstOp.genRand(bw, rng, concSamples);
          const UConstRange ucrLhs = std::get<0>(randUcr);
          const UConstRange ucrRhs = std::get<1>(randUcr);
          const UConstRange ucrBest = std::get<2>(randUcr);

          const Product prodLhs =
              reduce({KnownBits::top(bw), ucrLhs, SConstRange::top(bw)});
          const Product prodRhs =
              reduce({KnownBits::top(bw), ucrRhs, SConstRange::top(bw)});
          const Product prodBest =
              reduce({KnownBits::top(bw), ucrBest, SConstRange::top(bw)});

          r.push_back({prodLhs, prodRhs, prodBest});
        } else {
          std::tuple<SConstRange, SConstRange, SConstRange> randScr =
              scrEvalAbstOp.genRand(bw, rng, concSamples);
          const SConstRange scrLhs = std::get<0>(randScr);
          const SConstRange scrRhs = std::get<1>(randScr);
          const SConstRange scrBest = std::get<2>(randScr);

          const Product prodLhs =
              reduce({KnownBits::top(bw), UConstRange::top(bw), scrLhs});
          const Product prodRhs =
              reduce({KnownBits::top(bw), UConstRange::top(bw), scrRhs});
          const Product prodBest =
              reduce({KnownBits::top(bw), UConstRange::top(bw), scrBest});

          r.push_back({prodLhs, prodRhs, prodBest});
        }
      }
    }

    return r;
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
          if (!isBottom(reducedVal))
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
