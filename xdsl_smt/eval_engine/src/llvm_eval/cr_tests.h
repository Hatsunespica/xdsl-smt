#include <functional>
#include <iostream>
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

typedef std::function<const A::APInt(const A::APInt, const A::APInt)> concFn;
typedef std::function<bool(const A::APInt, const A::APInt)> opConFn;
typedef std::function<const llvm::ConstantRange(const llvm::ConstantRange &,
                                                const llvm::ConstantRange &)>
    crXferFn;
typedef std::tuple<std::string, concFn, std::optional<opConFn>, crXferFn>
    crTest;

inline llvm::ConstantRange make_llvm_cr(const ConstantRange &x) {
  if (x.isTop())
    return llvm::ConstantRange::getFull(x.bw());
  if (x.isBottom())
    return llvm::ConstantRange::getEmpty(x.bw());

  return llvm::ConstantRange(llvm::APInt(x.bw(), x.v[0].getZExtValue()),
                             llvm::APInt(x.bw(), x.v[1].getZExtValue()) + 1);
}

inline const ConstantRange
to_best_cr_abst(const ConstantRange &lhs, const ConstantRange &rhs,
                const concFn &fn, const std::optional<opConFn> &opCon) {
  std::vector<ConstantRange> crtVals;
  const std::vector<unsigned int> rhss = rhs.toConcrete();

  for (unsigned int lhs_v : lhs.toConcrete()) {
    for (unsigned int rhs_v : rhss) {
      if (!opCon ||
          opCon.value()(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v)))
        crtVals.push_back(ConstantRange::fromConcrete(
            fn(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v))));
    }
  }

  return ConstantRange::joinAll(crtVals, lhs.bw());
}

// inline const ConstantRange
// to_best_cr_abst_v(const ConstantRange &lhs, const ConstantRange &rhs,
//                   const concFn &fn, const std::optional<opConFn> &opCon) {
//   std::vector<ConstantRange> crtVals;
//   const std::vector<unsigned int> rhss = rhs.toConcrete();
//
//   for (unsigned int lhs_v : lhs.toConcrete()) {
//     for (unsigned int rhs_v : rhss) {
//       if (!opCon ||
//           opCon.value()(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(),
//           rhs_v))) {
//         auto lhs_ = A::APInt(lhs.bw(), lhs_v);
//         auto rhs_ = A::APInt(lhs.bw(), rhs_v);
//         std::cout << "lhs: " << lhs_.getZExtValue() << " | "
//                   << lhs_.getSExtValue() << "\n";
//         std::cout << "rhs: " << rhs_.getZExtValue() << " | "
//                   << rhs_.getSExtValue() << "\n";
//         std::cout << "res: " << fn(lhs_, rhs_).getZExtValue() << " | "
//                   << fn(lhs_, rhs_).getSExtValue() << "\n";
//         std::cout << "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n";
//         crtVals.push_back(ConstantRange::fromConcrete(
//             fn(A::APInt(lhs.bw(), lhs_v), A::APInt(lhs.bw(), rhs_v))));
//       }
//     }
//   }
//
//   return ConstantRange::joinAll(crtVals, lhs.bw());
// }

inline const ConstantRange cr_xfer_wrapper(const ConstantRange &lhs,
                                           const ConstantRange &rhs,
                                           const crXferFn &fn) {
  llvm::ConstantRange x = fn(make_llvm_cr(lhs), make_llvm_cr(rhs));

  if (x.isWrappedSet()) {
    std::cout << "wrapped\n";
    std::cout << x.getLower().getSExtValue() << " "
              << x.getLower().getZExtValue() << "\n";
    std::cout << x.getUpper().getSExtValue() << " "
              << x.getUpper().getZExtValue() << "\n";
    auto a = ConstantRange({A::APInt(lhs.bw(), x.getUpper().getZExtValue()),
                        A::APInt(lhs.bw(), x.getLower().getZExtValue()) - 1});
    std::cout << "A: " << a.display() << "\n";
    return ConstantRange::top(lhs.bw());
  }
  if (x.isFullSet()) {
    std::cout << "full\n";
    return ConstantRange::top(lhs.bw());
  }
  if (x.isEmptySet()) {
    std::cout << "empty\n";
    return ConstantRange::bottom(lhs.bw());
  }

  std::cout << "normal\n";
  return ConstantRange({A::APInt(lhs.bw(), x.getLower().getZExtValue()),
                        A::APInt(lhs.bw(), x.getUpper().getZExtValue()) - 1});
}

const std::vector<crTest> cr_tests{
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
};
const std::vector<crTest> cr_tests_{
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
