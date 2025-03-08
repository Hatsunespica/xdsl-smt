#pragma once

#include <cassert>
#include <climits>
#include <cstdint>
#include <cstring>
#include <optional>

class APInt;

inline APInt operator-(APInt);

class [[nodiscard]] APInt {
private:
  static inline int64_t SignExtend64(uint64_t X, unsigned B) {
    assert(B <= 64 && "Bit width out of range.");
    if (B == 0)
      return 0;
    return int64_t(X << (64 - B)) >> (64 - B);
  }

public:
  typedef uint64_t WordType;
  static constexpr uint64_t WORDTYPE_MAX = ~uint64_t(0);
  static constexpr unsigned APINT_WORD_SIZE = sizeof(uint64_t);
  static constexpr unsigned APINT_BITS_PER_WORD = APINT_WORD_SIZE * 8;

  explicit APInt() {
    VAL = 0;
    BitWidth = 1;
  }

  APInt(unsigned numBits, uint64_t val) : BitWidth(numBits), VAL(val) {
    clearUnusedBits();
  }

  /// Copy Constructor.
  APInt(const APInt &that) : BitWidth(that.BitWidth) { VAL = that.VAL; }

  static APInt getZero(unsigned numBits) { return APInt(numBits, 0); }
  static APInt getZeroWidth() { return getZero(0); }
  static APInt getMaxValue(unsigned numBits) { return getAllOnes(numBits); }
  static APInt getMinValue(unsigned numBits) { return APInt(numBits, 0); }

  static APInt getSignedMaxValue(unsigned numBits) {
    APInt API = getAllOnes(numBits);
    API.clearBit(numBits - 1);
    return API;
  }

  static APInt getSignedMinValue(unsigned numBits) {
    APInt API(numBits, 0);
    API.setBit(numBits - 1);
    return API;
  }

  static APInt getSignMask(unsigned BitWidth) {
    return getSignedMinValue(BitWidth);
  }

  static APInt getAllOnes(unsigned numBits) {
    return APInt(numBits, WORDTYPE_MAX);
  }

  static APInt getOneBitSet(unsigned numBits, unsigned BitNo) {
    APInt Res(numBits, 0);
    Res.setBit(BitNo);
    return Res;
  }

  static APInt getSplat(unsigned NewLen, const APInt &V);

  bool isNegative() const { return (*this)[BitWidth - 1]; }
  bool isNonNegative() const { return !isNegative(); }
  bool isSignBitSet() const { return (*this)[BitWidth - 1]; }
  bool isSignBitClear() const { return !isSignBitSet(); }
  bool isStrictlyPositive() const { return isNonNegative() && !isZero(); }
  bool isNonPositive() const { return !isStrictlyPositive(); }
  bool isZero() const { return VAL == 0; }
  bool isOne() const { return VAL == 1; }
  bool isMaxValue() const { return isAllOnes(); }
  bool isMinValue() const { return isZero(); }
  bool isIntN(unsigned N) const { return getActiveBits() <= N; }
  bool isSignedIntN(unsigned N) const { return getSignificantBits() <= N; }
  bool isSignMask() const { return isMinSignedValue(); }
  bool getBoolValue() const { return !isZero(); }
  bool isSplat(unsigned SplatSizeInBits) const;
  APInt getHiBits(unsigned numBits) const;
  APInt getLoBits(unsigned numBits) const;
  bool isOneBitSet(unsigned BitNo) const {
    return (*this)[BitNo] && popcount() == 1;
  }

  bool isAllOnes() const {
    return VAL == WORDTYPE_MAX >> (APINT_BITS_PER_WORD - BitWidth);
  }

  bool isMaxSignedValue() const {
    return VAL == ((WordType(1) << (BitWidth - 1)) - 1);
  }

  bool isMinSignedValue() const {
    return VAL == (WordType(1) << (BitWidth - 1));
  }

  bool isNegatedPowerOf2() const {
    assert(BitWidth && "zero width values not allowed");
    if (isNonNegative())
      return false;
    // NegatedPowerOf2 - shifted mask in the top bits.
    unsigned LO = countl_one();
    unsigned TZ = countr_zero();
    return (LO + TZ) == BitWidth;
  }

  uint64_t getLimitedValue(uint64_t Limit = UINT64_MAX) const {
    return ugt(Limit) ? Limit : getZExtValue();
  }

  bool isMask(unsigned numBits) const {
    return VAL == (WORDTYPE_MAX >> (APINT_BITS_PER_WORD - numBits));
  }

  static bool isSameValue(const APInt &I1, const APInt &I2) {
    if (I1.getBitWidth() == I2.getBitWidth())
      return I1 == I2;

    if (I1.getBitWidth() > I2.getBitWidth())
      return I1 == I2.zext(I1.getBitWidth());

    return I1.zext(I2.getBitWidth()) == I2;
  }

  APInt operator++(int) {
    APInt API(*this);
    ++(*this);
    return API;
  }

  APInt &operator++();

  APInt operator--(int) {
    APInt API(*this);
    --(*this);
    return API;
  }

  APInt &operator--();

  bool operator!() const { return isZero(); }

  APInt &operator=(const APInt &RHS) {
    VAL = RHS.VAL;
    BitWidth = RHS.BitWidth;
    return *this;
  }

  /// Move assignment operator.
  APInt &operator=(APInt &&that) {
    assert(this != &that && "Self-move not supported");
    VAL = that.BitWidth;
    BitWidth = that.BitWidth;
    that.BitWidth = 0;
    return *this;
  }

  APInt &operator=(uint64_t RHS) {
    VAL = RHS;
    return clearUnusedBits();
  }

  APInt &operator&=(const APInt &RHS) {
    VAL &= RHS.VAL;
    return *this;
  }

  APInt &operator&=(uint64_t RHS) {
    VAL &= RHS;
    return *this;
  }

  APInt &operator|=(const APInt &RHS) {
    VAL |= RHS.VAL;
    return *this;
  }

  APInt &operator|=(uint64_t RHS) {
    VAL |= RHS;
    return clearUnusedBits();
  }

  APInt &operator^=(const APInt &RHS) {
    VAL ^= RHS.VAL;
    return *this;
  }

  APInt &operator^=(uint64_t RHS) {
    VAL ^= RHS;
    return clearUnusedBits();
  }

  APInt &operator*=(const APInt &RHS);
  APInt &operator*=(uint64_t RHS);
  APInt &operator+=(const APInt &RHS);
  APInt &operator+=(uint64_t RHS);
  APInt &operator-=(const APInt &RHS);
  APInt &operator-=(uint64_t RHS);

  APInt &operator<<=(unsigned ShiftAmt) {
    if (ShiftAmt == BitWidth)
      VAL = 0;
    else
      VAL <<= ShiftAmt;
    return clearUnusedBits();
    return *this;
  }

  APInt &operator<<=(const APInt &ShiftAmt);
  APInt operator*(const APInt &RHS) const;
  APInt operator<<(unsigned Bits) const { return shl(Bits); }
  APInt operator<<(const APInt &Bits) const { return shl(Bits); }

  APInt ashr(unsigned ShiftAmt) const {
    APInt R(*this);
    R.ashrInPlace(ShiftAmt);
    return R;
  }

  void ashrInPlace(unsigned ShiftAmt) {
    int64_t SExtVAL = SignExtend64(VAL, BitWidth);
    if (ShiftAmt == BitWidth)
      VAL = SExtVAL >> (APINT_BITS_PER_WORD - 1); // Fill with sign bit.
    else
      VAL = SExtVAL >> ShiftAmt;
    clearUnusedBits();
    return;
  }

  APInt lshr(unsigned shiftAmt) const {
    APInt R(*this);
    R.lshrInPlace(shiftAmt);
    return R;
  }

  void lshrInPlace(unsigned ShiftAmt) {
    if (ShiftAmt == BitWidth)
      VAL = 0;
    else
      VAL >>= ShiftAmt;
    return;
  }

  APInt shl(unsigned shiftAmt) const {
    APInt R(*this);
    R <<= shiftAmt;
    return R;
  }

  APInt relativeLShr(int RelativeShift) const {
    return RelativeShift > 0 ? lshr(RelativeShift) : shl(-RelativeShift);
  }

  APInt relativeLShl(int RelativeShift) const {
    return relativeLShr(-RelativeShift);
  }

  APInt relativeAShr(int RelativeShift) const {
    return RelativeShift > 0 ? ashr(RelativeShift) : shl(-RelativeShift);
  }

  APInt relativeAShl(int RelativeShift) const {
    return relativeAShr(-RelativeShift);
  }

  APInt rotl(unsigned rotateAmt) const;
  APInt rotr(unsigned rotateAmt) const;

  APInt ashr(const APInt &ShiftAmt) const {
    APInt R(*this);
    R.ashrInPlace(ShiftAmt);
    return R;
  }

  void ashrInPlace(const APInt &shiftAmt);

  APInt lshr(const APInt &ShiftAmt) const {
    APInt R(*this);
    R.lshrInPlace(ShiftAmt);
    return R;
  }

  void lshrInPlace(const APInt &ShiftAmt);

  APInt shl(const APInt &ShiftAmt) const {
    APInt R(*this);
    R <<= ShiftAmt;
    return R;
  }

  APInt rotl(const APInt &rotateAmt) const;
  APInt rotr(const APInt &rotateAmt) const;
  APInt udiv(const APInt &RHS) const;
  APInt udiv(uint64_t RHS) const;
  APInt sdiv(const APInt &RHS) const;
  APInt sdiv(int64_t RHS) const;
  APInt urem(const APInt &RHS) const;
  uint64_t urem(uint64_t RHS) const;
  APInt srem(const APInt &RHS) const;
  int64_t srem(int64_t RHS) const;
  static void udivrem(const APInt &LHS, const APInt &RHS, APInt &Quotient,
                      APInt &Remainder);
  static void udivrem(const APInt &LHS, uint64_t RHS, APInt &Quotient,
                      uint64_t &Remainder);
  static void sdivrem(const APInt &LHS, const APInt &RHS, APInt &Quotient,
                      APInt &Remainder);
  static void sdivrem(const APInt &LHS, int64_t RHS, APInt &Quotient,
                      int64_t &Remainder);
  APInt sadd_ov(const APInt &RHS, bool &Overflow) const;
  APInt uadd_ov(const APInt &RHS, bool &Overflow) const;
  APInt ssub_ov(const APInt &RHS, bool &Overflow) const;
  APInt usub_ov(const APInt &RHS, bool &Overflow) const;
  APInt sdiv_ov(const APInt &RHS, bool &Overflow) const;
  APInt smul_ov(const APInt &RHS, bool &Overflow) const;
  APInt umul_ov(const APInt &RHS, bool &Overflow) const;
  APInt sshl_ov(const APInt &Amt, bool &Overflow) const;
  APInt sshl_ov(unsigned Amt, bool &Overflow) const;
  APInt ushl_ov(const APInt &Amt, bool &Overflow) const;
  APInt ushl_ov(unsigned Amt, bool &Overflow) const;
  APInt sfloordiv_ov(const APInt &RHS, bool &Overflow) const;
  APInt sadd_sat(const APInt &RHS) const;
  APInt uadd_sat(const APInt &RHS) const;
  APInt ssub_sat(const APInt &RHS) const;
  APInt usub_sat(const APInt &RHS) const;
  APInt smul_sat(const APInt &RHS) const;
  APInt umul_sat(const APInt &RHS) const;
  APInt sshl_sat(const APInt &RHS) const;
  APInt sshl_sat(unsigned RHS) const;
  APInt ushl_sat(const APInt &RHS) const;
  APInt ushl_sat(unsigned RHS) const;

  bool operator[](unsigned bitPosition) const {
    return maskBit(bitPosition) != 0;
  }

  bool operator==(const APInt &RHS) const { return VAL == RHS.VAL; }
  bool operator==(uint64_t Val) const { return getZExtValue() == Val; }
  bool eq(const APInt &RHS) const { return (*this) == RHS; }
  bool operator!=(const APInt &RHS) const { return !((*this) == RHS); }
  bool operator!=(uint64_t Val) const { return !((*this) == Val); }
  bool ne(const APInt &RHS) const { return !((*this) == RHS); }
  bool ult(const APInt &RHS) const { return compare(RHS) < 0; }
  bool ult(uint64_t RHS) const { return getZExtValue() < RHS; }
  bool slt(const APInt &RHS) const { return compareSigned(RHS) < 0; }
  bool slt(int64_t RHS) const { return getSExtValue() < RHS; }
  bool ule(const APInt &RHS) const { return compare(RHS) <= 0; }
  bool ule(uint64_t RHS) const { return !ugt(RHS); }
  bool sle(const APInt &RHS) const { return compareSigned(RHS) <= 0; }
  bool sle(uint64_t RHS) const { return !sgt(RHS); }
  bool ugt(const APInt &RHS) const { return !ule(RHS); }
  bool ugt(uint64_t RHS) const { return getZExtValue() > RHS; }
  bool sgt(const APInt &RHS) const { return !sle(RHS); }
  bool sgt(int64_t RHS) const { return getSExtValue() > RHS; }
  bool uge(const APInt &RHS) const { return !ult(RHS); }
  bool uge(uint64_t RHS) const { return !ult(RHS); }
  bool sge(const APInt &RHS) const { return !slt(RHS); }
  bool sge(int64_t RHS) const { return !slt(RHS); }
  bool intersects(const APInt &RHS) const { return (VAL & RHS.VAL) != 0; }
  bool isSubsetOf(const APInt &RHS) const { return (VAL & ~RHS.VAL) == 0; }

  APInt trunc(unsigned width) const;
  APInt truncUSat(unsigned width) const;
  APInt truncSSat(unsigned width) const;
  APInt zext(unsigned width) const;
  APInt sext(unsigned width) const;
  APInt zextOrTrunc(unsigned width) const;
  APInt sextOrTrunc(unsigned width) const;

  void setAllBits() {
    VAL = WORDTYPE_MAX;
    clearUnusedBits();
  }

  void setBit(unsigned BitPosition) {
    assert(BitPosition < BitWidth && "BitPosition out of range");
    WordType Mask = maskBit(BitPosition);
    VAL |= Mask;
  }

  void setSignBit() { setBit(BitWidth - 1); }

  void setBitVal(unsigned BitPosition, bool BitValue) {
    if (BitValue)
      setBit(BitPosition);
    else
      clearBit(BitPosition);
  }

  void clearAllBits() { VAL = 0; }

  void clearBit(unsigned BitPosition) {
    assert(BitPosition < BitWidth && "BitPosition out of range");
    WordType Mask = ~maskBit(BitPosition);
    VAL &= Mask;
  }

  void clearSignBit() { clearBit(BitWidth - 1); }

  void flipAllBits() {
    VAL ^= WORDTYPE_MAX;
    clearUnusedBits();
  }

  void negate() {
    flipAllBits();
    ++(*this);
  }

  void flipBit(unsigned bitPosition);
  void insertBits(const APInt &SubBits, unsigned bitPosition);
  void insertBits(uint64_t SubBits, unsigned bitPosition, unsigned numBits);
  APInt extractBits(unsigned numBits, unsigned bitPosition) const;
  uint64_t extractBitsAsZExtValue(unsigned numBits, unsigned bitPosition) const;
  unsigned getBitWidth() const { return BitWidth; }
  unsigned getNumWords() const { return getNumWords(BitWidth); }
  unsigned getActiveBits() const { return BitWidth - countl_zero(); }

  static unsigned getNumWords(unsigned BitWidth) {
    return ((uint64_t)BitWidth + APINT_BITS_PER_WORD - 1) / APINT_BITS_PER_WORD;
  }

  unsigned getSignificantBits() const {
    return BitWidth - getNumSignBits() + 1;
  }

  uint64_t getZExtValue() const { return VAL; }
  int64_t getSExtValue() const { return SignExtend64(VAL, BitWidth); }

  std::optional<uint64_t> tryZExtValue() const {
    return (getActiveBits() <= 64) ? std::optional<uint64_t>(getZExtValue())
                                   : std::nullopt;
  };

  std::optional<int64_t> trySExtValue() const {
    return (getSignificantBits() <= 64) ? std::optional<int64_t>(getSExtValue())
                                        : std::nullopt;
  };

  unsigned countl_zero() const {
    unsigned unusedBits = APINT_BITS_PER_WORD - BitWidth;
    return (VAL == 0 ? 64 : __builtin_clzll(VAL)) - unusedBits;
    // return llvm::countl_zero(VAL) - unusedBits;
  }

  unsigned countl_one() const {
    uint64_t tmp = ~(VAL << (APINT_BITS_PER_WORD - BitWidth));
    return tmp == 0 ? 64 : __builtin_clzll(tmp);
    // return llvm::countl_one(VAL << (APINT_BITS_PER_WORD - BitWidth));
  }

  unsigned getNumSignBits() const {
    return isNegative() ? countl_one() : countl_zero();
  }

  unsigned countr_zero() const {
    unsigned TrailingZeros = __builtin_ctzll(VAL);
    return (TrailingZeros > BitWidth ? BitWidth : TrailingZeros);
  }

  unsigned countLeadingZeros() const { return countl_zero(); }
  unsigned countLeadingOnes() const { return countl_one(); }
  unsigned countTrailingZeros() const { return countr_zero(); }
  unsigned countr_one() const { return __builtin_clzll(~VAL); }
  unsigned countTrailingOnes() const { return countr_one(); }
  unsigned popcount() const { return __builtin_popcountll(VAL); }
  APInt byteSwap() const;
  APInt reverseBits() const;
  double roundToDouble(bool isSigned) const;
  double roundToDouble() const { return roundToDouble(false); }
  double signedRoundToDouble() const { return roundToDouble(true); }
  unsigned logBase2() const { return getActiveBits() - 1; }

  unsigned ceilLogBase2() const {
    APInt temp(*this);
    --temp;
    return temp.getActiveBits();
  }

  unsigned nearestLogBase2() const;

  APInt abs() const {
    if (isNegative())
      return -(*this);
    return *this;
  }

  APInt multiplicativeInverse() const;

private:
  unsigned BitWidth;
  uint64_t VAL;

  static uint64_t maskBit(unsigned bitPosition) { return 1ULL << bitPosition; }

  APInt &clearUnusedBits() {
    // Compute how many bits are used in the final word.
    unsigned WordBits = ((BitWidth - 1) % APINT_BITS_PER_WORD) + 1;

    // Mask out the high bits.
    uint64_t mask = WORDTYPE_MAX >> (APINT_BITS_PER_WORD - WordBits);
    if (BitWidth == 0)
      mask = 0;

    VAL &= mask;
    return *this;
  }

  int compare(const APInt &RHS) const;
  int compareSigned(const APInt &RHS) const;
};

inline bool operator==(uint64_t V1, const APInt &V2) { return V2 == V1; }
inline bool operator!=(uint64_t V1, const APInt &V2) { return V2 != V1; }
inline APInt operator~(APInt v) {
  v.flipAllBits();
  return v;
}

inline APInt operator&(APInt a, const APInt &b) {
  a &= b;
  return a;
}

inline APInt operator&(const APInt &a, APInt &&b) {
  b &= a;
  return std::move(b);
}

inline APInt operator&(APInt a, uint64_t RHS) {
  a &= RHS;
  return a;
}

inline APInt operator&(uint64_t LHS, APInt b) {
  b &= LHS;
  return b;
}

inline APInt operator|(APInt a, const APInt &b) {
  a |= b;
  return a;
}

inline APInt operator|(const APInt &a, APInt &&b) {
  b |= a;
  return std::move(b);
}

inline APInt operator|(APInt a, uint64_t RHS) {
  a |= RHS;
  return a;
}

inline APInt operator|(uint64_t LHS, APInt b) {
  b |= LHS;
  return b;
}

inline APInt operator^(APInt a, const APInt &b) {
  a ^= b;
  return a;
}

inline APInt operator^(const APInt &a, APInt &&b) {
  b ^= a;
  return std::move(b);
}

inline APInt operator^(APInt a, uint64_t RHS) {
  a ^= RHS;
  return a;
}

inline APInt operator^(uint64_t LHS, APInt b) {
  b ^= LHS;
  return b;
}
inline APInt operator+(APInt a, const APInt &b) {
  a += b;
  return a;
}

inline APInt operator+(const APInt &a, APInt &&b) {
  b += a;
  return std::move(b);
}

inline APInt operator+(APInt a, uint64_t RHS) {
  a += RHS;
  return a;
}

inline APInt operator+(uint64_t LHS, APInt b) {
  b += LHS;
  return b;
}

inline APInt operator-(APInt a, const APInt &b) {
  a -= b;
  return a;
}
inline APInt operator-(const APInt &a, APInt &&b) {
  b.negate();
  b += a;
  return std::move(b);
}

inline APInt operator-(APInt a, uint64_t RHS) {
  a -= RHS;
  return a;
}

inline APInt operator-(uint64_t LHS, APInt b) {
  b.negate();
  b += LHS;
  return b;
}

inline APInt operator*(APInt a, uint64_t RHS) {
  a *= RHS;
  return a;
}

inline APInt operator*(uint64_t LHS, APInt b) {
  b *= LHS;
  return b;
}

inline APInt operator-(APInt v) {
  v.negate();
  return v;
}

namespace APIntOps {
/// Determine the smaller of two APInts considered to be signed.
inline const APInt &smin(const APInt &A, const APInt &B) {
  return A.slt(B) ? A : B;
}

/// Determine the larger of two APInts considered to be signed.
inline const APInt &smax(const APInt &A, const APInt &B) {
  return A.sgt(B) ? A : B;
}

/// Determine the smaller of two APInts considered to be unsigned.
inline const APInt &umin(const APInt &A, const APInt &B) {
  return A.ult(B) ? A : B;
}

/// Determine the larger of two APInts considered to be unsigned.
inline const APInt &umax(const APInt &A, const APInt &B) {
  return A.ugt(B) ? A : B;
}

/// Determine the absolute difference of two APInts considered to be signed.
inline const APInt abds(const APInt &A, const APInt &B) {
  return A.sge(B) ? (A - B) : (B - A);
}

/// Determine the absolute difference of two APInts considered to be unsigned.
inline const APInt abdu(const APInt &A, const APInt &B) {
  return A.uge(B) ? (A - B) : (B - A);
}

APInt avgFloorS(const APInt &C1, const APInt &C2);
APInt avgFloorU(const APInt &C1, const APInt &C2);
APInt avgCeilS(const APInt &C1, const APInt &C2);
APInt avgCeilU(const APInt &C1, const APInt &C2);
APInt mulhs(const APInt &C1, const APInt &C2);
APInt mulhu(const APInt &C1, const APInt &C2);
APInt GreatestCommonDivisor(APInt A, APInt B);

std::optional<unsigned> GetMostSignificantDifferentBit(const APInt &A,
                                                       const APInt &B);
} // namespace APIntOps
