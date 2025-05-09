#include <optional>
#include <vector>

#include "../APInt.h"
#include "../AbstVal.h"
#include "../warning_suppresor.h"
#include "common.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/Support/KnownBits.h>
SUPPRESS_WARNINGS_END

inline llvm::KnownBits make_llvm_kb(const KnownBits &x) {
  llvm::KnownBits llvm = llvm::KnownBits(x.bw());
  llvm.Zero = x.v[0].getZExtValue();
  llvm.One = x.v[1].getZExtValue();
  return llvm;
}

inline const KnownBits kb_xfer_wrapper(const KnownBits &lhs,
                                       const KnownBits &rhs,
                                       const XferFn<llvm::KnownBits> &fn) {
  llvm::KnownBits x = fn(make_llvm_kb(lhs), make_llvm_kb(rhs));
  return KnownBits({A::APInt(lhs.bw(), x.Zero.getZExtValue()),
                    A::APInt(lhs.bw(), x.One.getZExtValue())});
}

const std::vector<Test<llvm::KnownBits>> kb_tests{
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
        getNW(&A::APInt::sadd_ov),
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs, true, false);
        },
    },
    {
        "add nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        getNW(&A::APInt::uadd_ov),
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::add(lhs, rhs, false, true);
        },
    },
    {
        "add nsw nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        combine(getNW(&A::APInt::sadd_ov), getNW(&A::APInt::uadd_ov)),
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
        getNW(&A::APInt::ssub_ov),
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs, true, false);
        },
    },
    {
        "sub nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        getNW(&A::APInt::usub_ov),
        [](const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
          return llvm::KnownBits::sub(lhs, rhs, false, true);
        },
    },
    {
        "sub nsw nuw",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        combine(getNW(&A::APInt::ssub_ov), getNW(&A::APInt::usub_ov)),
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
