#include "common.h"
#include "../APInt.h"

bool nonZeroRhs(const A::APInt &_, const A::APInt &rhs) { return !rhs == 0; }
bool validShftAmnt(const A::APInt &l, const A::APInt &r) {
  return r.getZExtValue() < l.getBitWidth();
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
    tests{
        {"and", OP(l &r), std::nullopt},
        {"or", OP(l | r), std::nullopt},
        {"xor", OP(l ^ r), std::nullopt},
        {"add", OP(l + r), std::nullopt},
        {"add nsw", OP(l + r), getNW(&A::APInt::sadd_ov)},
        {"add nuw", OP(l + r), getNW(&A::APInt::uadd_ov)},
        {"add nsuw", OP(l + r), getNW(&A::APInt::sadd_ov, &A::APInt::uadd_ov)},
        {"sub", OP(l - r), std::nullopt},
        {"sub nsw", OP(l - r), getNW(&A::APInt::ssub_ov)},
        {"sub nuw", OP(l - r), getNW(&A::APInt::usub_ov)},
        {"sub nsuw", OP(l - r), getNW(&A::APInt::ssub_ov, &A::APInt::usub_ov)},
        {"umax", OP(A::APIntOps::umax(l, r)), std::nullopt},
        {"umin", OP(A::APIntOps::umin(l, r)), std::nullopt},
        {"smax", OP(A::APIntOps::smax(l, r)), std::nullopt},
        {"smin", OP(A::APIntOps::smin(l, r)), std::nullopt},
        {"abdu", OP(A::APIntOps::abdu(l, r)), std::nullopt},
        {"abds", OP(A::APIntOps::abds(l, r)), std::nullopt},
        {"udiv", OP(l.udiv(r)), nonZeroRhs},
        {"udiv exact", OP(l.udiv(r)), nonZeroRhs},
        {"sdiv", OP(l.sdiv(r)), nonZeroRhs},
        {"sdiv exact", OP(l.sdiv(r)), nonZeroRhs},
        {"urem", OP(l.urem(r)), nonZeroRhs},
        {"srem", OP(l.srem(r)), nonZeroRhs},
        {"mul", OP(l *r), std::nullopt},
        {"mul nsw", OP(l *r), getNW(&A::APInt::smul_ov)},
        {"mul nuw", OP(l *r), getNW(&A::APInt::umul_ov)},
        {"mul nsuw", OP(l *r), getNW(&A::APInt::smul_ov, &A::APInt::umul_ov)},
        {"mulhs", OP(A::APIntOps::mulhs(l, r)), std::nullopt},
        {"mulhu", OP(A::APIntOps::mulhu(l, r)), std::nullopt},
        {"shl", OP(l.shl(r)), validShftAmnt},
        {"shl nsw", OP(l.shl(r)), getNW(&A::APInt::sshl_ov)},
        {"shl nuw", OP(l.shl(r)), getNW(&A::APInt::ushl_ov)},
        {"shl nsuw", OP(l.shl(r)),
         getNW(&A::APInt::sshl_ov, &A::APInt::ushl_ov)},
        {"lshr", OP(l.lshr(r)), validShftAmnt},
        {"lshr exact", OP(l.lshr(r)), validShftAmnt},
        {"ashr", OP(l.ashr(r)), validShftAmnt},
        {"ashr exact", OP(l.ashr(r)), validShftAmnt},
        {"avgfloors", OP(A::APIntOps::avgFloorS(l, r)), std::nullopt},
        {"avgflooru", OP(A::APIntOps::avgFloorU(l, r)), std::nullopt},
        {"avgceils", OP(A::APIntOps::avgCeilS(l, r)), std::nullopt},
        {"avgceilu", OP(A::APIntOps::avgCeilU(l, r)), std::nullopt},
        {"uadd sat", OP(l.uadd_sat(r)), std::nullopt},
        {"usub sat", OP(l.usub_sat(r)), std::nullopt},
        {"sadd sat", OP(l.sadd_sat(r)), std::nullopt},
        {"ssub sat", OP(l.ssub_sat(r)), std::nullopt},
        {"umul sat", OP(l.umul_sat(r)), std::nullopt},
        {"smul sat", OP(l.smul_sat(r)), std::nullopt},
        {"ushl sat", OP(l.ushl_sat(r)), std::nullopt},
        {"sshl sat", OP(l.sshl_sat(r)), std::nullopt},
    };
