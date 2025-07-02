#ifndef AbstVal_H
#define AbstVal_H

#include <iostream>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <vector>

#include "APInt.h"

template <typename D>
concept AbstractDomain = requires(const D d, unsigned int bw, const A::APInt &a,
                                  const std::vector<D> &v, std::mt19937 &rng,
                                  unsigned char *p, unsigned int o) {
  std::constructible_from<D, Vec<D::N>>;
  { D::N } -> std::convertible_to<unsigned int>;
  { d.v } -> std::same_as<const Vec<D::N> &>;

  // Static methods
  { D::rand(rng, bw) } -> std::same_as<const D>;
  { D::bottom(bw) } -> std::same_as<const D>;
  { D::top(bw) } -> std::same_as<const D>;
  { D::enumVals(bw) } -> std::same_as<const std::vector<D>>;
  { D::fromConcrete(a) } -> std::same_as<const D>;
  { D::deserialize(p, o) } -> std::same_as<const D>;
  { D::joinAll(v, bw) } -> std::same_as<const D>;
  { D::meetAll(v, bw) } -> std::same_as<const D>;

  // Instance methods
  { d == d } -> std::convertible_to<bool>;
  { d.serialize(p, o) } -> std::same_as<void>;
  { d.isSuperset(d) } -> std::same_as<bool>;
  { d.isBottom() } -> std::same_as<bool>;
  { d.isTop() } -> std::same_as<bool>;
  { d.meet(d) } -> std::same_as<const D>;
  { d.join(d) } -> std::same_as<const D>;
  { d.toConcrete() } -> std::same_as<const std::vector<A::APInt>>;
  { d.getRandConcrete(rng) } -> std::same_as<const A::APInt>;
  { d.display() } -> std::same_as<const std::string>;
  { d.distance(d) } -> std::same_as<unsigned long>;
  { d.bw() } -> std::same_as<unsigned int>;
};

template <typename Domain, unsigned int N_> class AbstVal {
public:
  static constexpr unsigned int N = N_;
  Vec<N> v;

protected:
  AbstVal(const Vec<N> &x) : v(x) {}
  AbstVal(std::mt19937 &);

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

  static const Domain deserialize(unsigned char *ptr, unsigned int &offset) {
    return Vec<N>::deserialize(ptr, offset);
  }

  // normal methods
  bool operator==(const AbstVal &rhs) const { return v == rhs.v; }
  unsigned int bw() const { return v[0].getBitWidth(); }
  bool isTop() const { return *this == top(bw()); }
  bool isSuperset(const Domain &rhs) const { return meet(rhs) == rhs; }
  void serialize(unsigned char *p, unsigned int &o) const { v.serialize(p, o); }

  // methods delegated to derived class
  bool isBottom() const {
    return static_cast<const Domain *>(this)->isBottom();
  }
  const Domain meet(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->meet(rhs);
  }
  const Domain join(const Domain &rhs) const {
    return static_cast<const Domain *>(this)->join(rhs);
  }
  const std::vector<A::APInt> toConcrete() const {
    return static_cast<const Domain *>(this)->toConcrete();
  }
  const A::APInt getRandConcrete(std::mt19937 &rng) const {
    return static_cast<const Domain *>(this)->getRandConcrete(rng);
  }
  unsigned long distance(const Domain &rhs) const {
    return Domain::distance(rhs);
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

  bool isConstant() const {
    return zero().popcount() + one().popcount() == bw();
  }

  const A::APInt getConstant() const { return one(); }

public:
  KnownBits(const Vec<N> &vC) : AbstVal<KnownBits, N>(vC) {}

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

  bool isBottom() const { return zero().intersects(one()); }

  const KnownBits meet(const KnownBits &rhs) const {
    return KnownBits({zero() | rhs.zero(), one() | rhs.one()});
  }

  const KnownBits join(const KnownBits &rhs) const {
    return KnownBits({zero() & rhs.zero(), one() & rhs.one()});
  }

  const std::vector<A::APInt> toConcrete() const {
    std::vector<A::APInt> ret;
    const A::APInt min = A::APInt::getZero(bw());
    const A::APInt max = A::APInt::getMaxValue(bw());

    for (A::APInt i = min;; ++i) {
      if ((zero() & i) == 0 && (one() & ~i) == 0)
        ret.push_back(i);

      if (i == max)
        break;
    }

    return ret;
  }

  const A::APInt getRandConcrete(std::mt19937 &rng) const {
    std::uniform_int_distribution<unsigned long> dist(
        0, A::APInt::getAllOnes(bw()).getZExtValue());

    A::APInt val = A::APInt(bw(), dist(rng));
    val &= ~zero();
    val |= one();

    return val;
  }

  unsigned long distance(const KnownBits &rhs) const {
    if (isBottom() && rhs.isBottom())
      return 0;

    if (isBottom())
      return rhs.bw() - (rhs.zero() ^ rhs.one()).popcount();

    if (rhs.isBottom())
      return bw() - (zero() ^ one()).popcount();

    return (zero() ^ rhs.zero()).popcount() + (one() ^ rhs.one()).popcount();
  }

  static const KnownBits rand(std::mt19937 &rng, unsigned int bw) {
    std::uniform_int_distribution<unsigned long> dist(
        0, A::APInt::getAllOnes(bw).getZExtValue());

    A::APInt zeros = A::APInt(bw, dist(rng));
    A::APInt ones = A::APInt(bw, dist(rng));
    const A::APInt makeUnknown = A::APInt(bw, dist(rng));
    const A::APInt resolveTo = A::APInt(bw, dist(rng));

    A::APInt conflicts = zeros & ones;
    zeros &= ~(conflicts & makeUnknown);
    ones &= ~(conflicts & makeUnknown);

    zeros &= ~(resolveTo & (conflicts & ~makeUnknown));
    ones &= ~(~resolveTo & (conflicts & ~makeUnknown));

    return KnownBits({zeros, ones});
  }

  static const KnownBits fromConcrete(const A::APInt &x) {
    return KnownBits({~x, x});
  }

  static const KnownBits bottom(unsigned int bw) {
    const A::APInt max = A::APInt::getMaxValue(bw);
    return KnownBits({max, max});
  }

  static const KnownBits top(unsigned int bw) {
    const A::APInt min = A::APInt::getMinValue(bw);
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

class UConstRange : public AbstVal<UConstRange, 2> {
private:
  A::APInt lower() const { return v[0]; }
  A::APInt upper() const { return v[1]; }

  bool isConstant() const { return lower() == upper(); }

  const A::APInt getConstant() const { return lower(); }

public:
  UConstRange(const Vec<N> &vC) : AbstVal<UConstRange, N>(vC) {}

  const std::string display() const {
    if (UConstRange::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;
    ss << '[' << lower().getZExtValue() << ", " << upper().getZExtValue()
       << ']';

    if (UConstRange::isTop())
      ss << " (top)";

    return ss.str();
  }

  bool isBottom() const { return lower().ugt(upper()); }

  const UConstRange meet(const UConstRange &rhs) const {
    A::APInt l = rhs.lower().ugt(lower()) ? rhs.lower() : lower();
    A::APInt u = rhs.upper().ult(upper()) ? rhs.upper() : upper();
    if (l.ugt(u))
      return bottom(bw());
    return UConstRange({std::move(l), std::move(u)});
  }

  const UConstRange join(const UConstRange &rhs) const {
    const A::APInt l = rhs.lower().ult(lower()) ? rhs.lower() : lower();
    const A::APInt u = rhs.upper().ugt(upper()) ? rhs.upper() : upper();
    return UConstRange({std::move(l), std::move(u)});
  }

  const std::vector<A::APInt> toConcrete() const {
    if (lower().ugt(upper()))
      return {};

    std::vector<A::APInt> ret;
    for (A::APInt x = lower(); x.ule(upper()); x += 1) {
      ret.push_back(x);

      if (x == A::APInt::getMaxValue(bw()))
        break;
    }

    return ret;
  }

  const A::APInt getRandConcrete(std::mt19937 &rng) const {
    std::uniform_int_distribution<unsigned long> dist(lower().getZExtValue(),
                                                      upper().getZExtValue());
    return A::APInt(bw(), dist(rng));
  }

  unsigned long distance(const UConstRange &rhs) const {
    if (isBottom() && rhs.isBottom())
      return 0;

    if (isBottom())
      return A::APIntOps::abdu(rhs.lower(), rhs.upper()).getZExtValue();

    if (rhs.isBottom())
      return A::APIntOps::abdu(lower(), upper()).getZExtValue();

    unsigned long ld = A::APIntOps::abdu(lower(), rhs.lower()).getZExtValue();
    unsigned long ud = A::APIntOps::abdu(upper(), rhs.upper()).getZExtValue();
    return static_cast<unsigned int>(ld + ud);
  }

  static const UConstRange rand(std::mt19937 &rng, unsigned int bw) {
    std::uniform_int_distribution<unsigned long> dist(
        0, A::APInt::getAllOnes(bw).getZExtValue());

    UConstRange ucr({A::APInt(bw, dist(rng)), A::APInt(bw, dist(rng))});
    if (ucr.isBottom()) {
      const A::APInt tmp = ucr.v[0];
      ucr.v[0] = ucr.v[1];
      ucr.v[1] = tmp;
    }

    return ucr;
  }

  static const UConstRange fromConcrete(const A::APInt &x) {
    return UConstRange({x, x});
  }

  static const UConstRange bottom(unsigned int bw) {
    const A::APInt min = A::APInt::getMinValue(bw);
    const A::APInt max = A::APInt::getMaxValue(bw);
    return UConstRange({max, min});
  }

  static const UConstRange top(unsigned int bw) {
    const A::APInt min = A::APInt::getMinValue(bw);
    const A::APInt max = A::APInt::getMaxValue(bw);
    return UConstRange({min, max});
  }

  static std::vector<UConstRange> const enumVals(unsigned int bw) {
    const unsigned int min =
        static_cast<unsigned int>(A::APInt::getMinValue(bw).getZExtValue());
    const unsigned int max =
        static_cast<unsigned int>(A::APInt::getMaxValue(bw).getZExtValue());
    A::APInt l = A::APInt(bw, 0);
    A::APInt u = A::APInt(bw, 0);
    std::vector<UConstRange> ret = {};

    for (unsigned int i = min; i <= max; ++i) {
      for (unsigned int j = i; j <= max; ++j) {
        l = i;
        u = j;
        ret.push_back(UConstRange({l, u}));
      }
    }

    return ret;
  }
};

class SConstRange : public AbstVal<SConstRange, 2> {
private:
  A::APInt lower() const { return v[0]; }
  A::APInt upper() const { return v[1]; }

  bool isConstant() const { return lower() == upper(); }

  const A::APInt getConstant() const { return lower(); }

public:
  SConstRange(const Vec<N> &vC) : AbstVal<SConstRange, N>(vC) {}

  const std::string display() const {
    if (SConstRange::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;
    ss << '[' << lower().getSExtValue() << ", " << upper().getSExtValue()
       << ']';

    if (SConstRange::isTop())
      ss << " (top)";

    return ss.str();
  }

  bool isBottom() const { return lower().sgt(upper()); }

  const SConstRange meet(const SConstRange &rhs) const {
    A::APInt l = rhs.lower().sgt(lower()) ? rhs.lower() : lower();
    A::APInt u = rhs.upper().slt(upper()) ? rhs.upper() : upper();
    if (l.sgt(u))
      return bottom(bw());
    return SConstRange({std::move(l), std::move(u)});
  }

  const SConstRange join(const SConstRange &rhs) const {
    const A::APInt l = rhs.lower().slt(lower()) ? rhs.lower() : lower();
    const A::APInt u = rhs.upper().sgt(upper()) ? rhs.upper() : upper();
    return SConstRange({std::move(l), std::move(u)});
  }

  const std::vector<A::APInt> toConcrete() const {
    if (lower().sgt(upper()))
      return {};

    std::vector<A::APInt> ret;
    for (A::APInt x = lower(); x.sle(upper()); x += 1) {
      ret.push_back(x);

      if (x == A::APInt::getSignedMaxValue(bw()))
        break;
    }

    return ret;
  }

  const A::APInt getRandConcrete(std::mt19937 &rng) const {
    std::uniform_int_distribution<long> dist(lower().getSExtValue(),
                                             upper().getSExtValue());
    return A::APInt(bw(), static_cast<unsigned long>(dist(rng)));
  }

  unsigned long distance(const SConstRange &rhs) const {
    if (isBottom() && rhs.isBottom())
      return 0;

    if (isBottom())
      return A::APIntOps::abds(rhs.lower(), rhs.upper()).getZExtValue();

    if (rhs.isBottom())
      return A::APIntOps::abds(lower(), upper()).getZExtValue();

    unsigned long ld = A::APIntOps::abds(lower(), rhs.lower()).getZExtValue();
    unsigned long ud = A::APIntOps::abds(upper(), rhs.upper()).getZExtValue();
    return static_cast<unsigned int>(ld + ud);
  }

  static const SConstRange rand(std::mt19937 &rng, unsigned int bw) {
    std::uniform_int_distribution<unsigned long> dist(
        0, A::APInt::getAllOnes(bw).getZExtValue());

    SConstRange scr({A::APInt(bw, dist(rng)), A::APInt(bw, dist(rng))});
    if (scr.isBottom()) {
      const A::APInt tmp = scr.v[0];
      scr.v[0] = scr.v[1];
      scr.v[1] = tmp;
    }

    return scr;
  }

  static const SConstRange fromConcrete(const A::APInt &x) {
    return SConstRange({x, x});
  }

  static const SConstRange bottom(unsigned int bw) {
    const A::APInt min = A::APInt::getSignedMinValue(bw);
    const A::APInt max = A::APInt::getSignedMaxValue(bw);
    return SConstRange({max, min});
  }

  static const SConstRange top(unsigned int bw) {
    const A::APInt min = A::APInt::getSignedMinValue(bw);
    const A::APInt max = A::APInt::getSignedMaxValue(bw);
    return SConstRange({min, max});
  }

  static std::vector<SConstRange> const enumVals(unsigned int bw) {
    const int min =
        static_cast<int>(A::APInt::getSignedMinValue(bw).getSExtValue());
    const int max =
        static_cast<int>(A::APInt::getSignedMaxValue(bw).getSExtValue());
    A::APInt l = A::APInt::getSignedMinValue(bw);
    A::APInt u = A::APInt::getSignedMinValue(bw);
    std::vector<SConstRange> ret = {};

    for (int i = min; i <= max; ++i) {
      for (int j = i; j <= max; ++j) {
        l = static_cast<unsigned long>(i);
        u = static_cast<unsigned long>(j);
        ret.push_back(SConstRange({l, u}));
      }
    }

    return ret;
  }
};

template <unsigned int N>
class IntegerModulo : public AbstVal<IntegerModulo<N>, N> {
private:
  unsigned long crt;
  unsigned long p;
  unsigned int numTs;

  const Vec<N> residues() const { return this->v; }

  bool isConstant() const { return numTs == 0; }
  const A::APInt getConstant() const { return A::APInt(this->bw(), crt); }

  bool isBadBottom() const {
    const unsigned long max = A::APInt::getMaxValue(this->bw()).getZExtValue();

    if (numTs == 0 && crt > max)
      return true;

    return false;
  }

  bool isBadSingleton() const {
    const unsigned long max = A::APInt::getMaxValue(this->bw()).getZExtValue();

    if (numTs != 0 && crt + p > max)
      return true;

    return false;
  }

  IntegerModulo(const Vec<N> &v_, unsigned long crt_, unsigned long p_,
                unsigned int numTs_)
      : AbstVal<IntegerModulo, N>(v_), crt(crt_), p(p_), numTs(numTs_) {}

  IntegerModulo(const Vec<N> &vC, bool fixBadVals)
      : AbstVal<IntegerModulo, N>(vC) {
    unsigned int numTs_ = 0;
    unsigned long p_ = 1;
    for (unsigned int i = 0; i < N; ++i)
      if (residues()[i] == IM::primes[i])
        numTs_ += 1;
      else if (!IM::primeOv(this->bw(), i))
        p_ *= IM::primes[i];

    numTs = numTs_;
    p = p_;
    unsigned long crt_ = 0;

    for (unsigned int i = 0; i < N; ++i) {
      if (residues()[i] == IM::primes[i] || IM::primeOv(this->bw(), i))
        continue;
      unsigned long pp = p / IM::primes[i];
      crt_ += residues()[i].getZExtValue() *
              IM::modInv(static_cast<long>(pp), IM::primes[i]) * pp;
    }

    crt = crt_ % p;

    for (unsigned int i = 0; i < N; ++i)
      if (IM::primeOv(this->bw(), i))
        this->v[i] = 0;

    if (fixBadVals) {
      if (isBadBottom())
        this->v = bottom(this->bw()).v;
      else if (isBadSingleton()) {
        this->v = fromConcrete(A::APInt(this->bw(), crt)).v;
      }
    }
  }

public:
  IntegerModulo(const Vec<N> &vC) : IntegerModulo(vC, true) {}

  const std::string display() const {
    if (IntegerModulo::isBottom()) {
      return "(bottom)";
    }

    std::stringstream ss;

    ss << "mods: ";
    for (unsigned int i = 0; i < N; ++i)
      if (residues()[i] == IM::primes[i] || IM::primeOv(this->bw(), i))
        ss << "T ";
      else
        ss << residues()[i].getZExtValue() << " ";

    if (IntegerModulo::isTop())
      ss << "(top)";

    return ss.str();
  }

  bool isBottom() const {
    if (isBadBottom() || isBadSingleton())
      return true;

    for (unsigned int i = 0; i < N; ++i)
      if (this->v[i].ugt(A::APInt(this->bw(), IM::primes[i])))
        return true;

    return false;
  }

  const IntegerModulo meet(const IntegerModulo &rhs) const {
    Vec<N> x(this->bw());

    for (unsigned int i = 0; i < N; ++i) {
      if (IM::primeOv(this->bw(), i))
        x[i] = 0;

      if (residues()[i] == rhs.residues()[i])
        x[i] = residues()[i];
      else if (residues()[i] == IM::primes[i])
        x[i] = rhs.residues()[i];
      else if (rhs.residues()[i] == IM::primes[i])
        x[i] = residues()[i];
      else
        return bottom(this->bw());
    }

    return IntegerModulo(x, false);
  }

  const IntegerModulo join(const IntegerModulo &rhs) const {
    Vec<N> x(this->bw());

    for (unsigned int i = 0; i < N; ++i) {
      if (IM::primeOv(this->bw(), i))
        x[i] = 0;

      if (residues()[i] == rhs.residues()[i])
        x[i] = residues()[i];
      else if (residues()[i] == IM::primes[i] + 1)
        return rhs;
      else if (rhs.residues()[i] == IM::primes[i] + 1)
        return *this;
      else
        x[i] = IM::primes[i];
    }

    return IntegerModulo(x, false);
  }

  const std::vector<A::APInt> toConcrete() const {
    const A::APInt acrt = A::APInt(this->bw(), crt);

    if (p > A::APInt::getMaxValue(this->bw()).getZExtValue())
      return {acrt};

    const A::APInt ap = A::APInt(this->bw(), p);
    std::vector<A::APInt> r;
    bool ov = false;
    for (A::APInt x = acrt; !ov; x = x.uadd_ov(ap, ov))
      r.push_back(x);

    return r;
  }

  const A::APInt getRandConcrete(std::mt19937 &rng) const {
    std::uniform_int_distribution<unsigned long> dist(
        0, A::APInt::getAllOnes(this->bw()).getZExtValue());

    A::APInt val = A::APInt(this->bw(), dist(rng));
    val *= p;
    val += crt;

    return val;
  }

  unsigned long distance(const IntegerModulo &rhs) const {
    if (isBottom() && rhs.isBottom())
      return 0;

    if (isBottom())
      return rhs.numTs;

    if (rhs.isBottom())
      return numTs;

    unsigned int d = 0;
    for (unsigned int i = 0; i < N; ++i)
      if (residues()[i] != rhs.residues()[i]) {
        if (residues()[i] == IM::primes[i] ||
            rhs.residues()[i] == IM::primes[i])
          d += 1;
        else
          d += 2;
      }

    return d;
  }

  static const IntegerModulo rand(std::mt19937 &rng, unsigned int bw) {
    IntegerModulo im{Vec<N>(bw)};
    do {
      for (unsigned int i = 0; i < N; ++i) {
        if (IM::primeOv(bw, i))
          continue;
        im.v[i] =
            std::uniform_int_distribution<unsigned long>(0, IM::primes[i])(rng);
      }
    } while (im.isBottom());

    return im;
  }

  static const IntegerModulo fromConcrete(const A::APInt &x) {
    Vec<N> r(x.getBitWidth());
    unsigned long p = 1;

    for (unsigned int i = 0; i < N; ++i) {
      if (IM::primeOv(x.getBitWidth(), i))
        continue;

      r[i] = x.urem(IM::primes[i]);
      p *= IM::primes[i];
    }

    return IntegerModulo(r, x.getZExtValue(), p, 0);
  }

  static const IntegerModulo top(unsigned int bw) {
    Vec<N> x(bw);
    for (unsigned int i = 0; i < N; ++i) {
      if (IM::primeOv(bw, i))
        continue;

      x[i] = IM::primes[i];
    }

    return IntegerModulo(x, 0, 1, N);
  }

  static const IntegerModulo bottom(unsigned int bw) {
    Vec<N> x(bw);
    unsigned long p = 1;
    for (unsigned int i = 0; i < N; ++i) {
      if (IM::primeOv(bw, i))
        continue;

      x[i] = IM::primes[i] + 1;
      p *= IM::primes[i];
    }

    return IntegerModulo(x, 0, p, 0);
  }

  static std::vector<IntegerModulo> const enumVals(unsigned int bw) {
    std::vector<IntegerModulo> r;
    Vec<N> x(bw);

    while (true) {
      IntegerModulo x_im(x, false);
      if (!x_im.isBadBottom() && !x_im.isBadSingleton())
        r.push_back(x_im);

      if (x_im.isTop())
        break;

      for (unsigned int i = 0; i < N; ++i) {
        if (x[i] != IM::primes[i] && !IM::primeOv(bw, i)) {
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

static_assert(AbstractDomain<KnownBits>);
static_assert(AbstractDomain<UConstRange>);
static_assert(AbstractDomain<SConstRange>);
static_assert(AbstractDomain<IntegerModulo<6>>);

#endif
