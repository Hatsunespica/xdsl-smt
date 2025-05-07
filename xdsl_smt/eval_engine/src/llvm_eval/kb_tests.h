#include <cassert>
#include <functional>
#include <optional>
#include <vector>

#include "../APInt.h"
#include "../AbstVal.h"
#include "../warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/Support/KnownBits.h>
SUPPRESS_WARNINGS_END

typedef std::function<const A::APInt(const A::APInt, const A::APInt)> concFn;
typedef std::function<bool(const A::APInt, const A::APInt)> opConFn;
typedef std::function<const llvm::KnownBits(const llvm::KnownBits &,
                                            const llvm::KnownBits &)>
    kbXferFn;
typedef std::tuple<std::string, concFn, std::optional<opConFn>, kbXferFn>
    kbTest;

inline bool nonZeroRhs(const A::APInt &_, const A::APInt &rhs) {
  return !rhs == 0;
}

inline llvm::KnownBits make_llvm_kbs(const KnownBits &x) {
  llvm::KnownBits llvm_kbs = llvm::KnownBits(x.bw());
  llvm_kbs.Zero = x.v[0].getZExtValue();
  llvm_kbs.One = x.v[1].getZExtValue();
  return llvm_kbs;
}

inline const KnownBits kb_xfer_wrapper(const KnownBits &lhs,
                                       const KnownBits &rhs,
                                       const kbXferFn &fn) {
  llvm::KnownBits x = fn(make_llvm_kbs(lhs), make_llvm_kbs(rhs));
  return KnownBits({A::APInt(lhs.bw(), x.Zero.getZExtValue()),
                    A::APInt(lhs.bw(), x.One.getZExtValue())});
}

inline const KnownBits to_best_kb_abst(const KnownBits &lhs, const KnownBits &rhs,
                           const concFn &fn,
                           const std::optional<opConFn> &opCon) {
  std::vector<KnownBits> crtVals;
  const std::vector<unsigned int> rhss = rhs.toConcrete();

  for (unsigned int lhs_v : lhs.toConcrete()) {
    for (unsigned int rhs_v : rhss) {
      if (!opCon ||
          opCon.value()(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v)))
        crtVals.push_back(KnownBits::fromConcrete(
            fn(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v))));
    }
  }

  return KnownBits::joinAll(crtVals, lhs.bw());
}

const std::vector<kbTest> tests{
    {
        "and",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs & rhs; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return lhs & rhs;
        },
    },
    {
        "or",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs | rhs; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return lhs | rhs;
        },
    },
    {
        "xor",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs ^ rhs; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return lhs ^ rhs;
        },
    },
    {
        "add",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs);
        },
    },
    {
        "add nsw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool ov = false;
          A::APInt _ = lhs.sadd_ov(rhs, ov);
          return !ov;
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs, true, false);
        },
    },
    {
        "add nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool ov = false;
          A::APInt _ = lhs.uadd_ov(rhs, ov);
          return !ov;
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs, false, true);
        },
    },
    {
        "add nsw nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool sov = false;
          bool uov = false;
          A::APInt _ = lhs.sadd_ov(rhs, sov);
          _ = lhs.uadd_ov(rhs, uov);
          return !(sov | uov);
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs, true, true);
        },
    },
    {

        "sub",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs);
        },
    },
    {
        "sub nsw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool ov = false;
          A::APInt _ = lhs.ssub_ov(rhs, ov);
          return !ov;
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs, true, false);
        },
    },
    {
        "sub nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool ov = false;
          A::APInt _ = lhs.usub_ov(rhs, ov);
          return !ov;
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs, false, true);
        },
    },
    {
        "sub nsw nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        [](const A::APInt lhs, const A::APInt rhs) {
          bool sov = false;
          bool uov = false;
          A::APInt _ = lhs.ssub_ov(rhs, sov);
          _ = lhs.usub_ov(rhs, uov);
          return !(sov | uov);
        },
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs, true, true);
        },
    },
    {
        "umax",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::umax(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::umax(lhs, rhs);
        },
    },
    {
        "umin",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::umin(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::umin(lhs, rhs);
        },
    },
    {
        "smax",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::smax(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::smax(lhs, rhs);
        },
    },
    {
        "smin",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::smin(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::smin(lhs, rhs);
        },
    },
    {
        "abdu",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::abdu(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::abdu(lhs, rhs);
        },
    },
    {
        "abds",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::abds(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::abds(lhs, rhs);
        },
    },
    {
        "udiv",
        [](const A::APInt l, const A::APInt r) { return l.udiv(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::udiv(lhs, rhs);
        },
    },
    {
        "udiv exact",
        [](const A::APInt l, const A::APInt r) { return l.udiv(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::udiv(lhs, rhs, true);
        },
    },
    {
        "sdiv",
        [](const A::APInt l, const A::APInt r) { return l.sdiv(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sdiv(lhs, rhs);
        },
    },
    {
        "sdiv exact",
        [](const A::APInt l, const A::APInt r) { return l.sdiv(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sdiv(lhs, rhs, true);
        },
    },
    {

        "urem",
        [](const A::APInt l, const A::APInt r) { return l.urem(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::urem(lhs, rhs);
        },
    },
    {
        "srem",
        [](const A::APInt l, const A::APInt r) { return l.srem(r); },
        nonZeroRhs,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::srem(lhs, rhs);
        },
    },
    {
        "mul",
        [](const A::APInt l, const A::APInt r) { return l * r; },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::mul(lhs, rhs);
        },
    },
    {
        "mulhs",
        [](const A::APInt l, const A::APInt r) {
          return A::APIntOps::mulhs(l, r);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::mulhs(lhs, rhs);
        },
    },
    {
        "mulhu",
        [](const A::APInt l, const A::APInt r) {
          return A::APIntOps::mulhu(l, r);
        },
        std::nullopt,
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::mulhu(lhs, rhs);
        },
    },
};
