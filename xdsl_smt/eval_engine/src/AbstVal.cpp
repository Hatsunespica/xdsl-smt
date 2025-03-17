#pragma once

#include <algorithm>
#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <numeric>
#include <sstream>
#include <string>
#include <vector>

#include "APInt.cpp"

template <typename Domain> class AbstVal {
protected:
  explicit AbstVal(const std::vector<A::APInt> &x, unsigned int bitwidth)
      : v(x), bw(bitwidth) {}

public:
  std::vector<A::APInt> v;
  unsigned int bw;

  // static ctors
  static const Domain bottom(unsigned int bw) { return Domain::bottom(bw); }
  static const Domain top(unsigned int bw) { return Domain::top(bw); }
  static const std::vector<Domain> enumVals() { return Domain::enumVals(); }

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
  bool isTop() const { return *this == top(bw); }
  bool isBottom() const { return *this == bottom(bw); }
  bool isSuperset(const Domain &rhs) const { return meet(rhs) == rhs; }
  unsigned int distance(const Domain &rhs) const {
    return (v[0] ^ rhs.v[0]).popcount() + (v[1] ^ rhs.v[1]).popcount();
  }

  bool operator==(const AbstVal &rhs) const {
    if (v.size() != rhs.v.size())
      return false;

    for (unsigned long i = 0; i < v.size(); ++i)
      if (v[i] != rhs.v[i])
        return false;

    return true;
  };

  // methods delegated to derived class
  bool isConstant() const {
    return static_cast<const Domain *>(this)->isConstant();
  };
  const A::APInt getConstant() const {
    return static_cast<const Domain *>(this)->getConstant();
  };
  const Domain meet(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->meet(rhs);
  };
  const Domain join(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->join(rhs);
  };
  const std::vector<unsigned int> toConcrete() const {
    return static_cast<const Domain *>(this)->toConcrete();
  };
  const std::string display() const {
    return static_cast<Domain>(this)->display();
  };
};

class KnownBits : public AbstVal<KnownBits> {
private:
  A::APInt zero() const { return v[0]; }
  A::APInt one() const { return v[1]; }
  bool hasConflict() const { return zero().intersects(one()); }

public:
  explicit KnownBits(const std::vector<A::APInt> &vC, unsigned int bwC)
      : AbstVal<KnownBits>(vC, bwC) {}

  const std::string display() const {
    if (KnownBits::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;

    for (unsigned int i = bw; i > 0; --i)
      ss << (one()[i - 1] ? '1' : zero()[i - 1] ? '0' : '?');

    if (isConstant())
      ss << getConstant().getZExtValue();

    if (KnownBits::isTop())
      ss << " (top)";

    return ss.str();
  }

  bool isConstant() const { return zero().popcount() + one().popcount() == bw; }

  const A::APInt getConstant() const {
    assert(isConstant());
    return zero();
  }

  const KnownBits meet(const KnownBits &rhs) const {
    return KnownBits({zero() | rhs.zero(), one() | rhs.one()}, bw);
  }

  const KnownBits join(const KnownBits &rhs) const {
    return KnownBits({zero() & rhs.zero(), one() & rhs.one()}, bw);
  }

  const std::vector<unsigned int> toConcrete() const {
    std::vector<unsigned int> ret;
    const unsigned int z = static_cast<unsigned int>(zero().getZExtValue());
    const unsigned int o = static_cast<unsigned int>(one().getZExtValue());
    const unsigned int min =
        static_cast<unsigned int>(A::APInt::getZero(bw).getZExtValue());
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw).getZExtValue());

    for (unsigned int i = min; i <= max; ++i)
      if ((z & i) == 0 && (o & ~i) == 0)
        ret.push_back(i);

    return ret;
  }

  static KnownBits fromConcrete(const A::APInt &x, unsigned int bw) {
    return KnownBits({~x, x}, bw);
  }

  static KnownBits bottom(unsigned int bw) {
    A::APInt max = A::APInt::getMaxValue(bw);
    return KnownBits({max, max}, bw);
  }

  static KnownBits top(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    return KnownBits({min, min}, bw);
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
        ret.push_back(KnownBits({zero, one}, bw));
      }
    }

    return ret;
  }
};

class ConstantRange : public AbstVal<ConstantRange> {
private:
  A::APInt lower() const { return v[0]; }
  A::APInt upper() const { return v[1]; }

public:
  explicit ConstantRange(const std::vector<A::APInt> &vC, unsigned int bwC)
      : AbstVal<ConstantRange>(vC, bwC) {}

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
      return bottom(bw);
    return ConstantRange({std::move(l), std::move(u)}, bw);
  }

  const ConstantRange join(const ConstantRange &rhs) const {
    const A::APInt l = rhs.lower().ult(lower()) ? rhs.lower() : lower();
    const A::APInt u = rhs.upper().ugt(upper()) ? rhs.upper() : upper();
    return ConstantRange({std::move(l), std::move(u)}, bw);
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

  static ConstantRange fromConcrete(const A::APInt &x, unsigned int bw) {
    return ConstantRange({x, x}, bw);
  }

  static ConstantRange bottom(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    A::APInt max = A::APInt::getMaxValue(bw);
    return ConstantRange({max, min}, bw);
  }

  static ConstantRange top(unsigned int bw) {
    A::APInt min = A::APInt::getMinValue(bw);
    A::APInt max = A::APInt::getMaxValue(bw);
    return ConstantRange({min, max}, bw);
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
        ret.push_back(ConstantRange({l, u}, bw));
      }
    }

    return ret;
  }
};

class IntegerModulo : public AbstVal<IntegerModulo> {
private:
  constexpr const static unsigned char n = 10;
  constexpr const static std::array<unsigned char, n> primes = {
      2, 3, 5, 7, 11, 13, 17, 19, 23, 29};
  // constexpr const static unsigned long P =
  //     std::accumulate(primes.begin(), primes.end(),
  //                     static_cast<unsigned int>(1), std::multiplies<>{});

  const std::vector<A::APInt> residues() const { return v; }

  static unsigned int modInv(unsigned int a, unsigned int b) {
    unsigned int b0 = b, t, q;
    unsigned int x0 = 0, x1 = 1;
    if (b == 1)
      return 1;
    while (a > 1) {
      q = a / b;
      t = b, b = a % b, a = t;
      t = x0, x0 = x1 - q * x0, x1 = t;
    }
    return (x1 < 0) ? x1 + b0 : x1;
  }

  unsigned int chineseRemainder() {
    unsigned int result = 0;
    unsigned long long p = 1;
    for (size_t i = 0; i < n; ++i) {
      if (residues()[i] != primes[i]) {
        p *= primes[i];
      }
    }

    for (size_t i = 0; i < n; ++i) {
      if (residues()[i] == primes[i])
        continue;
      unsigned int pp = static_cast<unsigned int>(p / primes[i]);
      result += residues()[i].getZExtValue() * modInv(pp, primes[i]) * pp;
    }
    return result % p;
  }

public:
  explicit IntegerModulo(const std::vector<A::APInt> &vC, unsigned int bwC)
      : AbstVal<IntegerModulo>(vC, bwC) {}

  const std::string display() const;

  bool isConstant() const;
  const A::APInt getConstant() const;

  const IntegerModulo meet(const IntegerModulo &rhs) const {
    std::vector<A::APInt> r(n);

    for (unsigned int i = 0; i < n; ++i) {
      if (residues()[i] == rhs.residues()[i])
        r[i] = residues()[i];
      else if (residues()[i] == primes[i])
        r[i] = rhs.residues()[i];
      else if (rhs.residues()[i] == primes[i])
        r[i] = residues()[i];
      else
        r[i] = A::APInt(bw, primes[i] + 1);
    }

    return IntegerModulo(r, bw);
  }

  const IntegerModulo join(const IntegerModulo &rhs) const {
    std::vector<A::APInt> r(n);

    for (unsigned int i = 0; i < n; ++i) {
      if (residues()[i] == rhs.residues()[i])
        r[i] = residues()[i];
      else
        r[i] = A::APInt(bw, primes[i]);
    }

    return IntegerModulo(r, bw);
  }

  const std::vector<unsigned int> toConcrete() const;

  static IntegerModulo fromConcrete(const A::APInt &x, unsigned int bw) {
    unsigned int xVal = static_cast<unsigned int>(x.getZExtValue());
    std::vector<A::APInt> v(primes.size());
    std::transform(
        primes.begin(), primes.end(), v.begin(),
        [xVal, bw](unsigned char pr) { return A::APInt(bw, xVal % pr); });

    return IntegerModulo(v, bw);
  }

  static IntegerModulo top(unsigned int bw) {
    std::vector<A::APInt> r(n);
    std::transform(primes.begin(), primes.end(), r.begin(),
                   [bw](unsigned int x) { return A::APInt(bw, x); });
    return IntegerModulo(r, bw);
  }

  static IntegerModulo bottom(unsigned int bw) {
    std::vector<A::APInt> r(n);
    std::transform(primes.begin(), primes.end(), r.begin(),
                   [bw](unsigned int x) { return A::APInt(bw, x + 1); });
    return IntegerModulo(r, bw);
  }

  static std::vector<IntegerModulo> const enumVals();
};
