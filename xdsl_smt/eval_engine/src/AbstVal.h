#ifndef AbstVal_H
#define AbstVal_H

#include <algorithm>
#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <iostream>
#include <numeric>
#include <ostream>
#include <sstream>
#include <string>
#include <vector>

#include "APInt.h"

template <typename Domain, unsigned int N> class AbstVal {
public:
  static const constexpr unsigned int n = N;
  typedef Vec<N> (*XferFn)(Vec<N>, Vec<N>);
  Vec<N> v;

protected:
  explicit AbstVal(const Vec<N> &x) : v(x) {}

public:
  // static ctors
  static const Domain bottom(unsigned int bw) { return Domain::bottom(bw); }
  static const Domain top(unsigned int bw) { return Domain::top(bw); }
  static const std::vector<Domain> enumVals(unsigned int bw) {
    return Domain::enumVals(bw);
  }

  static const Domain fromConcrete(const A::APInt &x) {
    return Domain::fromConcrete(x);
  }

  static const Domain joinAll(const std::vector<Domain> &v, unsigned int bw) {
    return std::accumulate(
        v.begin(), v.end(), bottom(bw),
        [](const Domain &lhs, const Domain &rhs) { return lhs.join(rhs); });
  }

  static const Domain meetAll(const std::vector<Domain> &v, unsigned int bw) {
    return std::accumulate(
        v.begin(), v.end(), top(bw),
        [](const Domain &lhs, const Domain &rhs) { return lhs.meet(rhs); });
  }

  // normal methods
  bool operator==(const AbstVal &rhs) const { return v == rhs.v; }
  unsigned int bw() const { return v[0].getBitWidth(); }
  bool isTop() const { return *this == top(bw()); }
  bool isBottom() const { return *this == bottom(bw()); }
  bool isSuperset(const Domain &rhs) const { return meet(rhs) == rhs; }
  // TODO this should be for every val in v
  unsigned int distance(const Domain &rhs) const {
    return (v[0] ^ rhs.v[0]).popcount() + (v[1] ^ rhs.v[1]).popcount();
  }

  // methods delegated to derived class
  bool isConstant() const {
    return static_cast<const Domain *>(this)->isConstant();
  }
  const A::APInt getConstant() const {
    return static_cast<const Domain *>(this)->getConstant();
  }
  const Domain meet(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->meet(rhs);
  }
  const Domain join(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->join(rhs);
  }
  const std::vector<unsigned int> toConcrete() const {
    return static_cast<const Domain *>(this)->toConcrete();
  }
  const std::string display() const {
    return static_cast<Domain>(this)->display();
  }
};

class KnownBits : public AbstVal<KnownBits, 2> {
private:
  A::APInt zero() const { return v[0]; }
  A::APInt one() const { return v[1]; }
  bool hasConflict() const { return zero().intersects(one()); }

public:
  explicit KnownBits(const Vec<n> &vC) : AbstVal<KnownBits, n>(vC) {}

  const std::string display() const {
    if (KnownBits::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;

    for (unsigned int i = bw(); i > 0; --i)
      ss << (one()[i - 1] ? '1' : zero()[i - 1] ? '0' : '?');

    if (isConstant())
      ss << " const: " << getConstant().getZExtValue();

    if (KnownBits::isTop())
      ss << " (top)";

    return ss.str();
  }

  bool isConstant() const {
    return zero().popcount() + one().popcount() == bw();
  }

  const A::APInt getConstant() const {
    assert(isConstant());
    return one();
  }

  const KnownBits meet(const KnownBits &rhs) const {
    return KnownBits({zero() | rhs.zero(), one() | rhs.one()});
  }

  const KnownBits join(const KnownBits &rhs) const {
    return KnownBits({zero() & rhs.zero(), one() & rhs.one()});
  }

  const std::vector<unsigned int> toConcrete() const {
    std::vector<unsigned int> ret;
    const unsigned int z = static_cast<unsigned int>(zero().getZExtValue());
    const unsigned int o = static_cast<unsigned int>(one().getZExtValue());
    const unsigned int min =
        static_cast<unsigned int>(A::APInt::getZero(bw()).getZExtValue());
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw()).getZExtValue());

    for (unsigned int i = min; i <= max; ++i)
      if ((z & i) == 0 && (o & ~i) == 0)
        ret.push_back(i);

    return ret;
  }

  static KnownBits fromConcrete(const A::APInt &x) {
    return KnownBits({~x, x});
  }

  static KnownBits bottom(unsigned int bw) {
    A::APInt max = A::APInt::getMaxValue(bw);
    return KnownBits({max, max});
  }

  static KnownBits top(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    return KnownBits({min, min});
  }

  static std::vector<KnownBits> const enumVals(unsigned int bw) {
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw).getZExtValue());
    A::APInt zero = A::APInt(bw, 0);
    A::APInt one = A::APInt(bw, 0);
    std::vector<KnownBits> ret;
    ret.reserve(max * max);

    for (unsigned int i = 0; i <= max; ++i) {
      unsigned char jmp = i % 2 + 1;
      for (unsigned int j = 0; j <= max; j += jmp) {
        if ((i & j) != 0)
          continue;

        zero = i;
        one = j;
        ret.push_back(KnownBits({zero, one}));
      }
    }

    return ret;
  }
};

class ConstantRange : public AbstVal<ConstantRange, 2> {
private:
  A::APInt lower() const { return v[0]; }
  A::APInt upper() const { return v[1]; }

public:
  explicit ConstantRange(const Vec<n> &vC) : AbstVal<ConstantRange, n>(vC) {}

  const std::string display() const {
    if (ConstantRange::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;
    ss << '[' << lower().getZExtValue() << ", " << upper().getZExtValue()
       << ']';

    if (ConstantRange::isTop())
      ss << " (top)";

    return ss.str();
  }

  bool isConstant() const { return lower() == upper(); }

  const A::APInt getConstant() const {
    assert(isConstant());
    return lower();
  }

  const ConstantRange meet(const ConstantRange &rhs) const {
    A::APInt l = rhs.lower().ugt(lower()) ? rhs.lower() : lower();
    A::APInt u = rhs.upper().ult(upper()) ? rhs.upper() : upper();
    if (l.ugt(u))
      return bottom(bw());
    return ConstantRange({std::move(l), std::move(u)});
  }

  const ConstantRange join(const ConstantRange &rhs) const {
    const A::APInt l = rhs.lower().ult(lower()) ? rhs.lower() : lower();
    const A::APInt u = rhs.upper().ugt(upper()) ? rhs.upper() : upper();
    return ConstantRange({std::move(l), std::move(u)});
  }

  const std::vector<unsigned int> toConcrete() const {
    unsigned int l = static_cast<unsigned int>(lower().getZExtValue());
    unsigned int u = static_cast<unsigned int>(upper().getZExtValue() + 1);

    if (l > u)
      return {};

    std::vector<unsigned int> ret(u - l);
    std::iota(ret.begin(), ret.end(), l);
    return ret;
  }

  static ConstantRange fromConcrete(const A::APInt &x) {
    return ConstantRange({x, x});
  }

  static ConstantRange bottom(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    A::APInt max = A::APInt::getMaxValue(bw);
    return ConstantRange({max, min});
  }

  static ConstantRange top(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    A::APInt max = A::APInt::getMaxValue(bw);
    return ConstantRange({min, max});
  }

  static std::vector<ConstantRange> const enumVals(unsigned int bw) {
    const unsigned int min =
        static_cast<unsigned int>(A::APInt::getMinValue(bw).getZExtValue());
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw).getZExtValue());
    A::APInt l = A::APInt(bw, 0);
    A::APInt u = A::APInt(bw, 0);
    std::vector<ConstantRange> ret = {top(bw)};

    for (unsigned int i = min; i <= max; ++i) {
      for (unsigned int j = i; j <= max; ++j) {
        l = i;
        u = j;
        ret.push_back(ConstantRange({l, u}));
      }
    }

    return ret;
  }
};

class IntegerModulo : public AbstVal<IntegerModulo, 3> {
private:
  constexpr const static std::array<unsigned char, n> primes = {2, 3, 5};
  unsigned int crt;
  unsigned int p;
  unsigned int numTs;

  const Vec<n> residues() const { return v; }

  bool isBadBottom() const {
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw()).getZExtValue());

    if (numTs == 0 && crt > max)
      return true;

    return false;
  }

  bool isBadSingleton() const {
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw()).getZExtValue());

    if (numTs == 1 && crt + p > max && static_cast<int>(crt - p) < 0)
      return true;

    return false;
  }

  static unsigned int modInv(int a, int b) {
    int b0 = b, t, q;
    int x0 = 0, x1 = 1;
    if (b == 1)
      return 1;
    while (a > 1) {
      q = a / b;
      t = b, b = a % b, a = t;
      t = x0, x0 = x1 - q * x0, x1 = t;
    }
    return static_cast<unsigned int>((x1 < 0) ? x1 + b0 : x1);
  }

  explicit IntegerModulo(const Vec<n> &vC, bool fixBadVals)
      : AbstVal<IntegerModulo, n>(vC) {
    unsigned int numTs_ = 0;
    unsigned int p_ = 1;
    unsigned int crt_ = 0;
    for (unsigned int i = 0; i < n; ++i)
      if (residues()[i] == primes[i])
        numTs_ += 1;
      else
        p_ *= primes[i];

    numTs = numTs_;
    p = p_;

    for (unsigned int i = 0; i < n; ++i) {
      if (residues()[i] == primes[i])
        continue;
      unsigned int pp = p / primes[i];
      crt_ += static_cast<unsigned int>(residues()[i].getZExtValue()) *
              modInv(static_cast<int>(pp), primes[i]) * pp;
    }

    crt = crt_ % p;

    if (fixBadVals) {
      if (isBadBottom())
        v = bottom(bw()).v;
      else if (isBadSingleton()) {
        v = fromConcrete(A::APInt(bw(), crt)).v;
      }
    }
  }

public:
  explicit IntegerModulo(const Vec<n> &vC) : IntegerModulo(vC, true) {}

  const std::string display() const {
    if (IntegerModulo::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;

    ss << "mods: ";
    for (unsigned int i = 0; i < n; ++i)
      if (residues()[i] == primes[i])
        ss << "T ";
      else
        ss << residues()[i].getZExtValue() << " ";

    ss << "vals: ";
    for (unsigned int x : toConcrete())
      ss << x << " ";

    if (IntegerModulo::isTop())
      ss << "(top)";

    return ss.str();
  }

  bool isConstant() const { return numTs == 0; }
  const A::APInt getConstant() const {
    assert(isConstant());
    return A::APInt(bw(), crt);
  }

  const IntegerModulo meet(const IntegerModulo &rhs) const {
    Vec<n> x(bw());

    for (unsigned int i = 0; i < n; ++i) {
      if (residues()[i] == rhs.residues()[i])
        x[i] = residues()[i];
      else if (residues()[i] == primes[i])
        x[i] = rhs.residues()[i];
      else if (rhs.residues()[i] == primes[i])
        x[i] = residues()[i];
      else
        return bottom(bw());
    }

    return IntegerModulo(x);
  }

  const IntegerModulo join(const IntegerModulo &rhs) const {
    Vec<n> x(bw());

    for (unsigned int i = 0; i < n; ++i)
      if (residues()[i] == rhs.residues()[i])
        x[i] = residues()[i];
      else if (residues()[i] == primes[i] + 1)
        x[i] = rhs.residues()[i];
      else if (rhs.residues()[i] == primes[i] + 1)
        x[i] = residues()[i];
      else
        x[i] = primes[i];

    return IntegerModulo(x);
  }

  const std::vector<unsigned int> toConcrete() const {
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw()).getZExtValue());

    std::vector<unsigned int> r;
    for (unsigned int x = crt; x <= max; x += p)
      r.push_back(x);

    return r;
  }

  static IntegerModulo fromConcrete(const A::APInt &x) {
    unsigned int xVal = static_cast<unsigned int>(x.getZExtValue());
    std::vector<A::APInt> r;

    for (unsigned int i = 0; i < n; ++i)
      r.push_back(A::APInt(x.getBitWidth(), xVal % primes[i]));

    return IntegerModulo(r.data());
  }

  static IntegerModulo top(unsigned int bw) {
    std::vector<A::APInt> r;
    std::transform(primes.begin(), primes.end(), std::back_inserter(r),
                   [bw](unsigned int x) { return A::APInt(bw, x); });
    return IntegerModulo(r.data());
  }

  static IntegerModulo bottom(unsigned int bw) {
    std::vector<A::APInt> r;
    std::transform(primes.begin(), primes.end(), std::back_inserter(r),
                   [bw](unsigned int x) { return A::APInt(bw, x + 1); });
    return IntegerModulo(r.data());
  }

  static std::vector<IntegerModulo> const enumVals(unsigned int bw) {
    std::vector<IntegerModulo> r;
    Vec<n> x(bw);

    while (true) {
      IntegerModulo x_im(x, false);
      if (!x_im.isBadBottom() && !x_im.isBadSingleton())
        r.push_back(x_im);

      if (x_im.isTop())
        break;

      for (unsigned int i = 0; i < n; ++i) {
        if (x[i] != primes[i]) {
          for (unsigned int j = 0; j < i; ++j)
            x[j] = 0;

          x[i] += 1;
          break;
        }
      }
    }

    return r;
  }
};

#endif
