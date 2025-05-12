#include <algorithm>
#include <iostream>
#include <optional>
#include <ranges>
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

#define KB_OP(e)                                                               \
  [](const llvm::KnownBits &l, const llvm::KnownBits &r) { return e; }

inline const std::vector<Test<llvm::KnownBits>> kb_tests() {
  const std::vector<
      std::tuple<std::string, std::optional<XferFn<llvm::KnownBits>>>>
      kb_tests{
          {"and", KB_OP(l & r)},
          {"or", KB_OP(l | r)},
          {"xor", KB_OP(l ^ r)},
          {"add", KB_OP(llvm::KnownBits::add(l, r))},
          {"add nsw", KB_OP(llvm::KnownBits::add(l, r, true, false))},
          {"add nuw", KB_OP(llvm::KnownBits::add(l, r, false, true))},
          {"add nsuw", KB_OP(llvm::KnownBits::add(l, r, true, true))},
          {"sub", KB_OP(llvm::KnownBits::sub(l, r))},
          {"sub nsw", KB_OP(llvm::KnownBits::sub(l, r, true, false))},
          {"sub nuw", KB_OP(llvm::KnownBits::sub(l, r, false, true))},
          {"sub nsuw", KB_OP(llvm::KnownBits::sub(l, r, true, true))},
          {"umax", KB_OP(llvm::KnownBits::umax(l, r))},
          {"umin", KB_OP(llvm::KnownBits::umin(l, r))},
          {"smax", KB_OP(llvm::KnownBits::smax(l, r))},
          {"smin", KB_OP(llvm::KnownBits::smin(l, r))},
          {"abdu", KB_OP(llvm::KnownBits::abdu(l, r))},
          {"abds", KB_OP(llvm::KnownBits::abds(l, r))},
          {"udiv", KB_OP(llvm::KnownBits::udiv(l, r))},
          {"udiv exact", KB_OP(llvm::KnownBits::udiv(l, r, true))},
          {"sdiv", KB_OP(llvm::KnownBits::sdiv(l, r))},
          {"sdiv exact", KB_OP(llvm::KnownBits::sdiv(l, r, true))},
          {"urem", KB_OP(llvm::KnownBits::urem(l, r))},
          {"srem", KB_OP(llvm::KnownBits::srem(l, r))},
          {"mul", KB_OP(llvm::KnownBits::mul(l, r))},
          {"mul nsw", std::nullopt},
          {"mul nuw", std::nullopt},
          {"mul nsuw", std::nullopt},
          {"mulhs", KB_OP(llvm::KnownBits::mulhs(l, r))},
          {"mulhu", KB_OP(llvm::KnownBits::mulhu(l, r))},
          {"shl", KB_OP(llvm::KnownBits::shl(l, r))},
          {"shl nsw", KB_OP(llvm::KnownBits::shl(l, r, false, true))},
          {"shl nuw", KB_OP(llvm::KnownBits::shl(l, r, true, false))},
          {"shl nsuw", KB_OP(llvm::KnownBits::shl(l, r, true, true))},
          {"lshr", KB_OP(llvm::KnownBits::lshr(l, r))},
          {"lshr exact", KB_OP(llvm::KnownBits::lshr(l, r, false, true))},
          {"ashr", KB_OP(llvm::KnownBits::ashr(l, r))},
          {"ashr exact", KB_OP(llvm::KnownBits::ashr(l, r, false, true))},
          {"avgfloors", KB_OP(llvm::KnownBits::avgFloorS(l, r))},
          {"avgflooru", KB_OP(llvm::KnownBits::avgFloorU(l, r))},
          {"avgceils", KB_OP(llvm::KnownBits::avgCeilS(l, r))},
          {"avgceilu", KB_OP(llvm::KnownBits::avgCeilU(l, r))},
          {"uadd sat", KB_OP(llvm::KnownBits::uadd_sat(l, r))},
          {"usub sat", KB_OP(llvm::KnownBits::usub_sat(l, r))},
          {"sadd sat", KB_OP(llvm::KnownBits::sadd_sat(l, r))},
          {"ssub sat", KB_OP(llvm::KnownBits::ssub_sat(l, r))},
          {"umul sat", std::nullopt},
          {"smul sat", std::nullopt},
          {"ushl sat", std::nullopt},
          {"sshl sat", std::nullopt},
      };

  if (tests.size() != kb_tests.size()) {
    std::cerr << "Test size mismatch: " << tests.size() << " | "
              << kb_tests.size() << "\n";
    exit(1);
  }

  std::vector<Test<llvm::KnownBits>> v;
  std::ranges::for_each(std::ranges::views::zip(tests, kb_tests),
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
