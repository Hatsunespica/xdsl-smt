#include <iostream>
#include <vector>

#include "APInt.h"
#include "AbstVal.h"

const static unsigned int N = 6;
typedef IntegerModulo<N> IntMod;

IntMod f(const IntMod &lhs, const IntMod &rhs) {
  std::vector<IntMod> v;

  for (auto lhs_c : lhs.toConcrete()) {
    for (auto rhs_c : rhs.toConcrete()) {
      A::APInt lhs_c_a(lhs.bw(), lhs_c);
      A::APInt rhs_c_a(lhs.bw(), rhs_c);

      bool f;
      auto a = lhs_c_a.uadd_ov(rhs_c_a, f);

      if (!f)
        v.push_back(IntMod::fromConcrete(a));
    }
  }

  return IntMod::joinAll(v, lhs.bw());
}

// IntMod mul_xfer(const IntMod &lhs, const IntMod &rhs) {
//   unsigned int bw = lhs.bw();
//   auto top = IntMod::top(bw).v;
//   std::vector<A::APInt> tmp(top.v, top.v + IntMod::n);
//
//   if (lhs.v[0] == 1 && rhs.v[0] == 1)
//     tmp[0] = 1;
//
//   if (lhs.v[1] == 2 && rhs.v[1] == 2)
//     tmp[1] = 1;
//   if ((lhs.v[1] == 2 && rhs.v[1] == 1) || (lhs.v[1] == 1 && rhs.v[1] == 2))
//     tmp[1] = 2;
//
//   if (lhs.v[0] == 0 || rhs.v[0] == 0)
//     tmp[0] = 0;
//   if (lhs.v[1] == 0 || rhs.v[1] == 0)
//     tmp[1] = 0;
//   if (lhs.v[2] == 0 || rhs.v[2] == 0)
//     tmp[2] = 0;
//
//   return IntMod(tmp.data());
// }

Vec<N> add_xfer_raw(const Vec<N> &lhs, const Vec<N> &rhs) {
  const unsigned int bw = lhs[0].getBitWidth();
  const A::APInt lhs_p = IM::prod(lhs);
  const A::APInt rhs_p = IM::prod(rhs);
  const A::APInt lhs_crt = IM::crt(lhs, lhs_p);
  const A::APInt rhs_crt = IM::crt(rhs, rhs_p);

  bool of = false;
  const A::APInt crt_sum = lhs_crt.uadd_ov(rhs_crt, of);
  if (of)
    return IM::bottom<N>(bw);

  Vec<N> tmp(bw);

  auto _ = crt_sum.uadd_ov(lhs_p, of);
  Vec small_lhs = of ? IM::fromConcrete<N>(lhs_crt) : lhs;
  auto __ = crt_sum.uadd_ov(rhs_p, of);
  Vec small_rhs = of ? IM::fromConcrete<N>(rhs_crt) : rhs;

  for (unsigned int i = 0; i < N; ++i)
    if (small_lhs[i] != IM::primes[i] && small_rhs[i] != IM::primes[i])
      tmp[i] = (small_lhs[i] + small_rhs[i]).urem(IM::primes[i]);
    else
      tmp[i] = IM::primes[i];

  return tmp;
}

IntMod add_xfer(const IntMod &lhs, const IntMod &rhs) {
  const unsigned int bw = lhs.bw();
  const A::APInt lhs_p = IM::prod(lhs.v);
  const A::APInt rhs_p = IM::prod(rhs.v);
  const A::APInt lhs_crt = IM::crt(lhs.v, lhs_p);
  const A::APInt rhs_crt = IM::crt(rhs.v, rhs_p);

  bool of = false;
  const A::APInt crt_sum = lhs_crt.uadd_ov(rhs_crt, of);
  if (of)
    return IntMod(IM::bottom<N>(bw));

  Vec<N> tmp(bw);

  auto _ = crt_sum.uadd_ov(lhs_p, of);
  Vec<N> small_lhs = of ? IM::fromConcrete<N>(lhs_crt) : lhs.v;
  auto __ = crt_sum.uadd_ov(rhs_p, of);
  Vec<N> small_rhs = of ? IM::fromConcrete<N>(rhs_crt) : rhs.v;

  for (unsigned int i = 0; i < N; ++i)
    if (small_lhs[i] != IM::primes[i] && small_rhs[i] != IM::primes[i])
      tmp[i] = (small_lhs[i] + small_rhs[i]).urem(IM::primes[i]);
    else
      tmp[i] = IM::primes[i];

  return IntMod(tmp);
}

bool vec_eq(const std::vector<unsigned int> &lhs,
            const std::vector<unsigned int> &rhs) {
  if (lhs.size() != rhs.size())
    return false;
  for (unsigned int i = 0; i < lhs.size(); ++i)
    if (lhs[i] != rhs[i])
      return false;
  return true;
}

int main() {
  unsigned int bw = 4;
  auto lattice = IntMod::enumVals(bw);

  for (auto lhs : lattice) {
    for (auto rhs : lattice) {
      auto res = f(lhs, rhs);
      auto ges = add_xfer(lhs, rhs);

      if (!(res == ges)) {
        std::cout << "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" << std::endl;
        std::cout << "lhs: " << lhs.display() << "\n";
        std::cout << "rhs: " << rhs.display() << "\n";
        std::cout << "res: " << res.display() << "\n";
        std::cout << "gue: " << ges.display() << "\n";
      }
    }
  }

  return 0;
}
