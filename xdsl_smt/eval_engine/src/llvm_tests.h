#include <optional>
#include <vector>

#include "APInt.h"
#include "AbstVal.h"
#include "utils.cpp"
#include "warning_suppresor.h"

SUPPRESS_WARNINGS_BEGIN
#include <llvm/ADT/APInt.h>
#include <llvm/IR/ConstantRange.h>
#include <llvm/Support/KnownBits.h>
SUPPRESS_WARNINGS_END

inline llvm::ConstantRange make_llvm_cr(const UConstRange &x) {
  if (x.isTop())
    return llvm::ConstantRange::getFull(x.bw());
  if (x.isBottom())
    return llvm::ConstantRange::getEmpty(x.bw());

  return llvm::ConstantRange(llvm::APInt(x.bw(), x.v[0].getZExtValue()),
                             llvm::APInt(x.bw(), x.v[1].getZExtValue()) + 1);
}

inline const UConstRange
cr_xfer_wrapper(const UConstRange &lhs, const UConstRange &rhs,
                const XferFn<llvm::ConstantRange> &fn) {
  llvm::ConstantRange x = fn(make_llvm_cr(lhs), make_llvm_cr(rhs));

  if (x.isWrappedSet())
    return UConstRange::top(lhs.bw());
  if (x.isFullSet())
    return UConstRange::top(lhs.bw());
  if (x.isEmptySet())
    return UConstRange::bottom(lhs.bw());

  return UConstRange({A::APInt(lhs.bw(), x.getLower().getZExtValue()),
                      A::APInt(lhs.bw(), x.getUpper().getZExtValue()) - 1});
}

#define CR_OP(e)                                                               \
  [](const llvm::ConstantRange &l, const llvm::ConstantRange &r) { return e; }

const std::vector<
    std::tuple<std::string, std::optional<XferFn<llvm::ConstantRange>>>>
    CR_TESTS{
        {"Abds", std::nullopt},
        {"Abdu", std::nullopt},
        {"Add", CR_OP(l.add(r))},
        {"AddNsw", CR_OP(l.addWithNoWrap(r, 2))},
        {"AddNswNuw", CR_OP(l.addWithNoWrap(r, 3))},
        {"AddNuw", CR_OP(l.addWithNoWrap(r, 1))},
        {"And", CR_OP(l.binaryAnd(r))},
        {"Ashr", CR_OP(l.ashr(r))},
        {"AshrExact", std::nullopt},
        {"AvgCeilS", std::nullopt},
        {"AvgCeilU", std::nullopt},
        {"AvgFloorS", std::nullopt},
        {"AvgFloorU", std::nullopt},
        {"Lshr", CR_OP(l.lshr(r))},
        {"LshrExact", std::nullopt},
        {"Mods", CR_OP(l.srem(r))},
        {"Modu", CR_OP(l.urem(r))},
        {"Mul", CR_OP(l.multiply(r))},
        {"MulNsw", CR_OP(l.multiplyWithNoWrap(r, 2))},
        {"MulNswNuw", CR_OP(l.multiplyWithNoWrap(r, 3))},
        {"MulNuw", CR_OP(l.multiplyWithNoWrap(r, 1))},
        {"Mulhs", std::nullopt},
        {"Mulhu", std::nullopt},
        {"Or", CR_OP(l.binaryOr(r))},
        {"SaddSat", CR_OP(l.sadd_sat(r))},
        {"Sdiv", CR_OP(l.sdiv(r))},
        {"SdivExact", std::nullopt},
        {"Shl", CR_OP(l.shl(r))},
        {"ShlNsw", CR_OP(l.shlWithNoWrap(r, 2))},
        {"ShlNswNuw", CR_OP(l.shlWithNoWrap(r, 3))},
        {"ShlNuw", CR_OP(l.shlWithNoWrap(r, 1))},
        {"Smax", CR_OP(l.smax(r))},
        {"Smin", CR_OP(l.smin(r))},
        {"SmulSat", CR_OP(l.smul_sat(r))},
        {"SshlSat", CR_OP(l.sshl_sat(r))},
        {"SsubSat", CR_OP(l.ssub_sat(r))},
        {"Sub", CR_OP(l.sub(r))},
        {"SubNsw", CR_OP(l.subWithNoWrap(r, 2))},
        {"SubNswNuw", CR_OP(l.subWithNoWrap(r, 3))},
        {"SubNuw", CR_OP(l.subWithNoWrap(r, 1))},
        {"UaddSat", CR_OP(l.uadd_sat(r))},
        {"Udiv", CR_OP(l.udiv(r))},
        {"UdivExact", std::nullopt},
        {"Umax", CR_OP(l.umax(r))},
        {"Umin", CR_OP(l.umin(r))},
        {"UmulSat", CR_OP(l.umul_sat(r))},
        {"UshlSat", CR_OP(l.ushl_sat(r))},
        {"UsubSat", CR_OP(l.usub_sat(r))},
        {"Xor", CR_OP(l.binaryXor(r))},
    };

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

const std::vector<
    std::tuple<std::string, std::optional<XferFn<llvm::KnownBits>>>>
    KB_TESTS{
        {"Abds", KB_OP(llvm::KnownBits::abds(l, r))},
        {"Abdu", KB_OP(llvm::KnownBits::abdu(l, r))},
        {"Add", KB_OP(llvm::KnownBits::add(l, r))},
        {"AddNsw", KB_OP(llvm::KnownBits::add(l, r, true, false))},
        {"AddNswNuw", KB_OP(llvm::KnownBits::add(l, r, true, true))},
        {"AddNuw", KB_OP(llvm::KnownBits::add(l, r, false, true))},
        {"And", KB_OP(l &r)},
        {"Ashr", KB_OP(llvm::KnownBits::ashr(l, r))},
        {"AshrExact", KB_OP(llvm::KnownBits::ashr(l, r, false, true))},
        {"AvgCeilS", KB_OP(llvm::KnownBits::avgCeilS(l, r))},
        {"AvgCeilU", KB_OP(llvm::KnownBits::avgCeilU(l, r))},
        {"AvgFloorS", KB_OP(llvm::KnownBits::avgFloorS(l, r))},
        {"AvgFloorU", KB_OP(llvm::KnownBits::avgFloorU(l, r))},
        {"Lshr", KB_OP(llvm::KnownBits::lshr(l, r))},
        {"LshrExact", KB_OP(llvm::KnownBits::lshr(l, r, false, true))},
        {"Mods", KB_OP(llvm::KnownBits::srem(l, r))},
        {"Modu", KB_OP(llvm::KnownBits::urem(l, r))},
        {"Mul", KB_OP(llvm::KnownBits::mul(l, r))},
        {"MulNsw", std::nullopt},
        {"MulNswNuw", std::nullopt},
        {"MulNuw", std::nullopt},
        {"Mulhs", KB_OP(llvm::KnownBits::mulhs(l, r))},
        {"Mulhu", KB_OP(llvm::KnownBits::mulhu(l, r))},
        {"Or", KB_OP(l | r)},
        {"SaddSat", KB_OP(llvm::KnownBits::sadd_sat(l, r))},
        {"Sdiv", KB_OP(llvm::KnownBits::sdiv(l, r))},
        {"SdivExact", KB_OP(llvm::KnownBits::sdiv(l, r, true))},
        {"Shl", KB_OP(llvm::KnownBits::shl(l, r))},
        {"ShlNsw", KB_OP(llvm::KnownBits::shl(l, r, false, true))},
        {"ShlNswNuw", KB_OP(llvm::KnownBits::shl(l, r, true, true))},
        {"ShlNuw", KB_OP(llvm::KnownBits::shl(l, r, true, false))},
        {"Smax", KB_OP(llvm::KnownBits::smax(l, r))},
        {"Smin", KB_OP(llvm::KnownBits::smin(l, r))},
        {"SmulSat", std::nullopt},
        {"SshlSat", std::nullopt},
        {"SsubSat", KB_OP(llvm::KnownBits::ssub_sat(l, r))},
        {"Sub", KB_OP(llvm::KnownBits::sub(l, r))},
        {"SubNsw", KB_OP(llvm::KnownBits::sub(l, r, true, false))},
        {"SubNswNuw", KB_OP(llvm::KnownBits::sub(l, r, true, true))},
        {"SubNuw", KB_OP(llvm::KnownBits::sub(l, r, false, true))},
        {"UaddSat", KB_OP(llvm::KnownBits::uadd_sat(l, r))},
        {"Udiv", KB_OP(llvm::KnownBits::udiv(l, r))},
        {"UdivExact", KB_OP(llvm::KnownBits::udiv(l, r, true))},
        {"Umax", KB_OP(llvm::KnownBits::umax(l, r))},
        {"Umin", KB_OP(llvm::KnownBits::umin(l, r))},
        {"UmulSat", std::nullopt},
        {"UshlSat", std::nullopt},
        {"UsubSat", KB_OP(llvm::KnownBits::usub_sat(l, r))},
        {"Xor", KB_OP(l ^ r)},
    };

inline const SConstRange scr_xfer_wrapper(const SConstRange &lhs,
                                          const SConstRange &_,
                                          const XferFn<std::nullopt_t> &fn) {
  (void)fn;
  return SConstRange::bottom(lhs.bw());
}

inline const IntegerModulo<6>
im_xfer_wrapper(const IntegerModulo<6> &lhs, const IntegerModulo<6> &_,
                const XferFn<std::nullopt_t> &fn) {
  (void)fn;
  return IntegerModulo<6>::bottom(lhs.bw());
}

const std::vector<
    std::tuple<std::string, std::optional<XferFn<std::nullopt_t>>>>
    EMPTY_TESTS{
        {"Abds", std::nullopt},      {"Abdu", std::nullopt},
        {"Add", std::nullopt},       {"AddNsw", std::nullopt},
        {"AddNswNuw", std::nullopt}, {"AddNuw", std::nullopt},
        {"And", std::nullopt},       {"Ashr", std::nullopt},
        {"AshrExact", std::nullopt}, {"AvgCeilS", std::nullopt},
        {"AvgCeilU", std::nullopt},  {"AvgFloorS", std::nullopt},
        {"AvgFloorU", std::nullopt}, {"Lshr", std::nullopt},
        {"LshrExact", std::nullopt}, {"Mods", std::nullopt},
        {"Modu", std::nullopt},      {"Mul", std::nullopt},
        {"MulNsw", std::nullopt},    {"MulNswNuw", std::nullopt},
        {"MulNuw", std::nullopt},    {"Mulhs", std::nullopt},
        {"Mulhu", std::nullopt},     {"Or", std::nullopt},
        {"SaddSat", std::nullopt},   {"Sdiv", std::nullopt},
        {"SdivExact", std::nullopt}, {"Shl", std::nullopt},
        {"ShlNsw", std::nullopt},    {"ShlNswNuw", std::nullopt},
        {"ShlNuw", std::nullopt},    {"Smax", std::nullopt},
        {"Smin", std::nullopt},      {"SmulSat", std::nullopt},
        {"SshlSat", std::nullopt},   {"SsubSat", std::nullopt},
        {"Sub", std::nullopt},       {"SubNsw", std::nullopt},
        {"SubNswNuw", std::nullopt}, {"SubNuw", std::nullopt},
        {"UaddSat", std::nullopt},   {"Udiv", std::nullopt},
        {"UdivExact", std::nullopt}, {"Umax", std::nullopt},
        {"Umin", std::nullopt},      {"UmulSat", std::nullopt},
        {"UshlSat", std::nullopt},   {"UsubSat", std::nullopt},
        {"Xor", std::nullopt},
    };
