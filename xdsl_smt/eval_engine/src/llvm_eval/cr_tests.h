#include <optional>
#include <ranges>
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

#define CR_OP(e)                                                               \
  [](const llvm::ConstantRange &l, const llvm::ConstantRange &r) { return e; }

inline const std::vector<Test<llvm::ConstantRange>> cr_tests() {
  const std::vector<
      std::tuple<std::string, std::optional<XferFn<llvm::ConstantRange>>>>
      cr_tests{
          {"and", CR_OP(l.binaryAnd(r))}, {"or", CR_OP(l.binaryOr(r))},
          {"xor", CR_OP(l.binaryXor(r))}, {"add", CR_OP(l.add(r))},
          {"sub", CR_OP(l.sub(r))},       {"umax", CR_OP(l.umax(r))},
          {"umin", CR_OP(l.umin(r))},     {"smax", CR_OP(l.smax(r))},
          {"smin", CR_OP(l.smin(r))},     {"udiv", CR_OP(l.udiv(r))},
          {"sdiv", CR_OP(l.sdiv(r))},     {"urem", CR_OP(l.urem(r))},
          {"srem", CR_OP(l.srem(r))},     {"mul", CR_OP(l.multiply(r))},
      };

  std::vector<Test<llvm::ConstantRange>> v;
  std::ranges::for_each(std::ranges::views::zip(tests, cr_tests),
                        [&v](const auto &pair) {
                          const auto &[test, kbTest] = pair;
                          const auto &[tName, concFn, opConFn] = test;
                          const auto &[kbName, kbOp] = kbTest;
                          assert(tName == kbName);
                          v.emplace_back(tName, concFn, opConFn, kbOp);
                        });

  return v;
}
