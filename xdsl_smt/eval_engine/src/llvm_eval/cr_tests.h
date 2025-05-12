#include <iostream>
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
          {"and", CR_OP(l.binaryAnd(r))},
          {"or", CR_OP(l.binaryOr(r))},
          {"xor", CR_OP(l.binaryXor(r))},
          {"add", CR_OP(l.add(r))},
          {"add nsw", CR_OP(l.addWithNoWrap(r, 2))},
          {"add nuw", CR_OP(l.addWithNoWrap(r, 1))},
          {"add nsuw", CR_OP(l.addWithNoWrap(r, 3))},
          {"sub", CR_OP(l.sub(r))},
          {"sub nsw", CR_OP(l.subWithNoWrap(r, 2))},
          {"sub nuw", CR_OP(l.subWithNoWrap(r, 1))},
          {"sub nsuw", CR_OP(l.subWithNoWrap(r, 3))},
          {"umax", CR_OP(l.umax(r))},
          {"umin", CR_OP(l.umin(r))},
          {"smax", CR_OP(l.smax(r))},
          {"smin", CR_OP(l.smin(r))},
          {"abdu", std::nullopt},
          {"abds", std::nullopt},
          {"udiv", CR_OP(l.udiv(r))},
          {"udiv exact", std::nullopt},
          {"sdiv", CR_OP(l.sdiv(r))},
          {"sdiv exact", std::nullopt},
          {"urem", CR_OP(l.urem(r))},
          {"srem", CR_OP(l.srem(r))},
          {"mul", CR_OP(l.multiply(r))},
          {"mul nsw", CR_OP(l.multiplyWithNoWrap(r, 2))},
          {"mul nuw", CR_OP(l.multiplyWithNoWrap(r, 1))},
          {"mul nsuw", CR_OP(l.multiplyWithNoWrap(r, 3))},
          {"mulhs", std::nullopt},
          {"mulhu", std::nullopt},
          {"shl", CR_OP(l.shl(r))},
          {"shl nsw", CR_OP(l.shlWithNoWrap(r, 2))},
          {"shl nuw", CR_OP(l.shlWithNoWrap(r, 1))},
          {"shl nsuw", CR_OP(l.shlWithNoWrap(r, 3))},
          {"lshr", CR_OP(l.lshr(r))},
          {"lshr exact", std::nullopt},
          {"ashr", CR_OP(l.ashr(r))},
          {"ashr exact", std::nullopt},
          {"avgfloors", std::nullopt},
          {"avgflooru", std::nullopt},
          {"avgceils", std::nullopt},
          {"avgceilu", std::nullopt},
          {"uadd sat", CR_OP(l.uadd_sat(r))},
          {"usub sat", CR_OP(l.usub_sat(r))},
          {"sadd sat", CR_OP(l.sadd_sat(r))},
          {"ssub sat", CR_OP(l.ssub_sat(r))},
          {"umul sat", CR_OP(l.umul_sat(r))},
          {"smul sat", CR_OP(l.smul_sat(r))},
          {"ushl sat", CR_OP(l.ushl_sat(r))},
          {"sshl sat", CR_OP(l.sshl_sat(r))},
      };

  if (tests.size() != cr_tests.size()) {
    std::cerr << "Test size mismatch: " << tests.size() << " | "
              << cr_tests.size() << "\n";
    exit(1);
  }

  std::vector<Test<llvm::ConstantRange>> v;
  std::ranges::for_each(std::ranges::views::zip(tests, cr_tests),
                        [&v](const auto &pair) {
                          const auto &[test, kbTest] = pair;
                          const auto &[tName, concFn, opConFn] = test;
                          const auto &[kbName, kbOp] = kbTest;
                          if (tName != kbName) {
                            std::cerr << "Function name mismatch: " << tName
                                      << " | " << kbName << "\n";
                            exit(1);
                          }
                          v.emplace_back(tName, concFn, opConFn, kbOp);
                        });

  return v;
}
