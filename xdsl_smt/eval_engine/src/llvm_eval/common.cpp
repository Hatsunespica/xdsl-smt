#include "common.h"
#include "../APInt.h"

bool nonZeroRhs(const A::APInt &_, const A::APInt &rhs) { return !rhs == 0; }

bool udivExact(const A::APInt &lhs, const A::APInt &rhs) {
  if (rhs == 0)
    return false;

  if (lhs.urem(rhs) != 0)
    return false;

  return true;
}

bool sdivExact(const A::APInt &lhs, const A::APInt &rhs) {
  if (rhs == 0)
    return false;

  if (lhs.srem(rhs) != 0)
    return false;

  return true;
}

bool validShftAmnt(const A::APInt &l, const A::APInt &r) {
  return r.getZExtValue() < l.getBitWidth();
}

bool shiftExact(const A::APInt &lhs, const A::APInt &rhs) {
  if (rhs.getZExtValue() >= lhs.getBitWidth())
    return false;

  return lhs.countr_zero() >= rhs.getZExtValue();
}

opConFn getNW(ovFn fn) {
  return [fn](const A::APInt lhs, const A::APInt rhs) {
    bool b;
    auto _ = std::bind(fn, lhs, rhs, std::ref(b))();
    return !b;
  };
}

opConFn getNW(ovFn fn0, ovFn fn1) {
  return [fn0, fn1](const A::APInt lhs, const A::APInt rhs) {
    bool b0;
    bool b1;
    auto _ = std::bind(fn0, lhs, rhs, std::ref(b0))();
    _ = std::bind(fn1, lhs, rhs, std::ref(b1))();
    return !b0 && !b1;
  };
}

#define OP(expr) [](const A::APInt l, const A::APInt r) { return expr; }

const std::vector<std::tuple<std::string, concFn, std::optional<opConFn>>>
    OP_TESTS{
        {"Abds", OP(A::APIntOps::abds(l, r)), std::nullopt},
        {"Abdu", OP(A::APIntOps::abdu(l, r)), std::nullopt},
        {"Add", OP(l + r), std::nullopt},
        {"AddNsw", OP(l + r), getNW(&A::APInt::sadd_ov)},
        {"AddNswNuw", OP(l + r), getNW(&A::APInt::sadd_ov, &A::APInt::uadd_ov)},
        {"AddNuw", OP(l + r), getNW(&A::APInt::uadd_ov)},
        {"And", OP(l &r), std::nullopt},
        {"Ashr", OP(l.ashr(r)), validShftAmnt},
        {"AshrExact", OP(l.ashr(r)), shiftExact},
        {"AvgCeilS", OP(A::APIntOps::avgCeilS(l, r)), std::nullopt},
        {"AvgCeilU", OP(A::APIntOps::avgCeilU(l, r)), std::nullopt},
        {"AvgFloorS", OP(A::APIntOps::avgFloorS(l, r)), std::nullopt},
        {"AvgFloorU", OP(A::APIntOps::avgFloorU(l, r)), std::nullopt},
        {"Lshr", OP(l.lshr(r)), validShftAmnt},
        {"LshrExact", OP(l.lshr(r)), shiftExact},
        {"Mods", OP(l.srem(r)), nonZeroRhs},
        {"Modu", OP(l.urem(r)), nonZeroRhs},
        {"Mul", OP(l *r), std::nullopt},
        {"MulNsw", OP(l *r), getNW(&A::APInt::smul_ov)},
        {"MulNswNuw", OP(l *r), getNW(&A::APInt::smul_ov, &A::APInt::umul_ov)},
        {"MulNuw", OP(l *r), getNW(&A::APInt::umul_ov)},
        {"Mulhs", OP(A::APIntOps::mulhs(l, r)), std::nullopt},
        {"Mulhu", OP(A::APIntOps::mulhu(l, r)), std::nullopt},
        {"Or", OP(l | r), std::nullopt},
        {"SaddSat", OP(l.sadd_sat(r)), std::nullopt},
        {"Sdiv", OP(l.sdiv(r)), nonZeroRhs},
        {"SdivExact", OP(l.sdiv(r)), sdivExact},
        {"Shl", OP(l.shl(r)), validShftAmnt},
        {"ShlNsw", OP(l.shl(r)), getNW(&A::APInt::sshl_ov)},
        {"ShlNswNuw", OP(l.shl(r)),
         getNW(&A::APInt::sshl_ov, &A::APInt::ushl_ov)},
        {"ShlNuw", OP(l.shl(r)), getNW(&A::APInt::ushl_ov)},
        {"Smax", OP(A::APIntOps::smax(l, r)), std::nullopt},
        {"Smin", OP(A::APIntOps::smin(l, r)), std::nullopt},
        {"SmulSat", OP(l.smul_sat(r)), std::nullopt},
        {"SshlSat", OP(l.sshl_sat(r)), std::nullopt},
        {"SsubSat", OP(l.ssub_sat(r)), std::nullopt},
        {"Sub", OP(l - r), std::nullopt},
        {"SubNsw", OP(l - r), getNW(&A::APInt::ssub_ov)},
        {"SubNswNuw", OP(l - r), getNW(&A::APInt::ssub_ov, &A::APInt::usub_ov)},
        {"SubNuw", OP(l - r), getNW(&A::APInt::usub_ov)},
        {"UaddSat", OP(l.uadd_sat(r)), std::nullopt},
        {"Udiv", OP(l.udiv(r)), nonZeroRhs},
        {"UdivExact", OP(l.udiv(r)), udivExact},
        {"Umax", OP(A::APIntOps::umax(l, r)), std::nullopt},
        {"Umin", OP(A::APIntOps::umin(l, r)), std::nullopt},
        {"UmulSat", OP(l.umul_sat(r)), std::nullopt},
        {"UshlSat", OP(l.ushl_sat(r)), std::nullopt},
        {"UsubSat", OP(l.usub_sat(r)), std::nullopt},
        {"Xor", OP(l ^ r), std::nullopt},
    };
