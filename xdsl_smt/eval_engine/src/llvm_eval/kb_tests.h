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
