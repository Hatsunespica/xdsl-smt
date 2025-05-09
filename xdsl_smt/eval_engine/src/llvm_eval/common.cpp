#include "common.h"
#include "../APInt.h"

bool nonZeroRhs(const A::APInt &_, const A::APInt &rhs) { return !rhs == 0; }

opConFn getNW(ovFn fn) {
  return [fn](const A::APInt lhs, const A::APInt rhs) {
    bool b;
    auto _ = std::bind(fn, lhs, rhs, std::ref(b))();
    return !b;
  };
}

opConFn combine(const opConFn &a, const opConFn &b) {
  return [a, b](const A::APInt lhs, const A::APInt rhs) {
    return a(lhs, rhs) && b(lhs, rhs);
  };
}
