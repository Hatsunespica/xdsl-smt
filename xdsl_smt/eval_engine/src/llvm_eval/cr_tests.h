#include <optional>
#include <vector>

#include "../APInt.h"
#include "../AbstVal.h"
#include "../warning_suppresor.h"
#include "common.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ADT/APInt.h>
#include <llvm/IR/ConstantRange.h>
SUPPRESS_WARNINGS_END

inline llvm::ConstantRange make_llvm_cr(const ConstantRange &x) {
  if (x.isTop())
    return llvm::ConstantRange::getFull(x.bw());
  if (x.isBottom())
    return llvm::ConstantRange::getEmpty(x.bw());

  return llvm::ConstantRange(llvm::APInt(x.bw(), x.v[0].getZExtValue()),
                             llvm::APInt(x.bw(), x.v[1].getZExtValue()) + 1);
}

inline const ConstantRange
cr_xfer_wrapper(const ConstantRange &lhs, const ConstantRange &rhs,
                const XferFn<llvm::ConstantRange> &fn) {
  llvm::ConstantRange x = fn(make_llvm_cr(lhs), make_llvm_cr(rhs));

  if (x.isWrappedSet())
    return ConstantRange::top(lhs.bw());
  if (x.isFullSet())
    return ConstantRange::top(lhs.bw());
  if (x.isEmptySet())
    return ConstantRange::bottom(lhs.bw());

  return ConstantRange({A::APInt(lhs.bw(), x.getLower().getZExtValue()),
                        A::APInt(lhs.bw(), x.getUpper().getZExtValue()) - 1});
}

const std::vector<Test<llvm::ConstantRange>> cr_tests{
    // TODO add nsw
    // TODO add nuw
    // TODO add nsw nuw
    // TODO sub nsw
    // TODO sub nuw
    // TODO sub nsw nuw
    // TODO mul nsw
    // TODO mul nuw
    // TODO mul nsw nuw
    {
        "and",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs & rhs; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.binaryAnd(rhs);
        },
    },
    {
        "or",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs | rhs; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.binaryOr(rhs);
        },
    },
    {
        "xor",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs ^ rhs; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.binaryXor(rhs);
        },
    },
    {
        "add",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs + rhs; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.add(rhs);
        },
    },
    {

        "sub",
        [](const A::APInt lhs, const A::APInt rhs) { return lhs - rhs; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.sub(rhs);
        },
    },
    {
        "umax",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::umax(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.umax(rhs);
        },
    },
    {
        "umin",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::umin(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.umin(rhs);
        },
    },
    {
        "smax",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::smax(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.smax(rhs);
        },
    },
    {
        "smin",
        [](const A::APInt lhs, const A::APInt rhs) {
          return A::APIntOps::smin(lhs, rhs);
        },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.smin(rhs);
        },
    },
    {
        "udiv",
        [](const A::APInt l, const A::APInt r) { return l.udiv(r); },
        nonZeroRhs,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.udiv(rhs);
        },
    },
    {
        "sdiv",
        [](const A::APInt l, const A::APInt r) { return l.sdiv(r); },
        nonZeroRhs,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.sdiv(rhs);
        },
    },
    {

        "urem",
        [](const A::APInt l, const A::APInt r) { return l.urem(r); },
        nonZeroRhs,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.urem(rhs);
        },
    },
    {
        "srem",
        [](const A::APInt l, const A::APInt r) { return l.srem(r); },
        nonZeroRhs,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.srem(rhs);
        },
    },
    {
        "mul",
        [](const A::APInt l, const A::APInt r) { return l * r; },
        std::nullopt,
        [](const llvm::ConstantRange &lhs, const llvm::ConstantRange &rhs) {
          return lhs.multiply(rhs);
        },
    },
    // TODO add to the end of the table here and for kb
};
