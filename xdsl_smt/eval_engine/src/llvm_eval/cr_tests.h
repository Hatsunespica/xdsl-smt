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
