#include "APInt.h"
#include <cmath>

APInt &APInt::operator++() {
  ++VAL;
  return clearUnusedBits();
}

APInt &APInt::operator--() {
  --VAL;
  return clearUnusedBits();
}

APInt &APInt::operator+=(const APInt &RHS) {
  VAL += RHS.VAL;
  return clearUnusedBits();
}

APInt &APInt::operator+=(uint64_t RHS) {
  VAL += RHS;
  return clearUnusedBits();
}

APInt &APInt::operator-=(const APInt &RHS) {
  VAL -= RHS.VAL;
  return clearUnusedBits();
}

APInt &APInt::operator-=(uint64_t RHS) {
  VAL -= RHS;
  return clearUnusedBits();
}

APInt APInt::operator*(const APInt &RHS) const {
  return APInt(BitWidth, VAL * RHS.VAL);
}

APInt &APInt::operator*=(const APInt &RHS) {
  *this = *this * RHS;
  return *this;
}

APInt &APInt::operator*=(uint64_t RHS) {
  VAL *= RHS;
  return clearUnusedBits();
}

int APInt::compare(const APInt &RHS) const {
  return VAL < RHS.VAL ? -1 : VAL > RHS.VAL;
}

int APInt::compareSigned(const APInt &RHS) const {
  int64_t lhsSext = SignExtend64(VAL, BitWidth);
  int64_t rhsSext = SignExtend64(RHS.VAL, BitWidth);
  return lhsSext < rhsSext ? -1 : lhsSext > rhsSext;
}

/// Toggle a given bit to its opposite value whose position is given
/// as "bitPosition".
/// Toggles a given bit to its opposite value.
void APInt::flipBit(unsigned bitPosition) {
  assert(bitPosition < BitWidth && "Out of the bit-width range!");
  setBitVal(bitPosition, !(*this)[bitPosition]);
}

bool APInt::isSplat(unsigned SplatSizeInBits) const {
  assert(getBitWidth() % SplatSizeInBits == 0 &&
         "SplatSizeInBits must divide width!");
  // We can check that all parts of an integer are equal by making use of a
  // little trick: rotate and check if it's still the same value.
  return *this == rotl(SplatSizeInBits);
}

/// This function returns the high "numBits" bits of this APInt.
APInt APInt::getHiBits(unsigned numBits) const {
  return this->lshr(BitWidth - numBits);
}

/// Return a value containing V broadcasted over NewLen bits.
APInt APInt::getSplat(unsigned NewLen, const APInt &V) {
  assert(NewLen >= V.getBitWidth() && "Can't splat to smaller bit width!");

  APInt Val = V.zext(NewLen);
  for (unsigned I = V.getBitWidth(); I < NewLen; I <<= 1)
    Val |= Val << I;

  return Val;
}

APInt APInt::trunc(unsigned width) const { return APInt(width, VAL); }

// Truncate to new width with unsigned saturation.
APInt APInt::truncUSat(unsigned width) const {
  assert(width <= BitWidth && "Invalid APInt Truncate request");

  // Can we just losslessly truncate it?
  if (isIntN(width))
    return trunc(width);
  // If not, then just return the new limit.
  return APInt::getMaxValue(width);
}

// Truncate to new width with signed saturation.
APInt APInt::truncSSat(unsigned width) const {
  assert(width <= BitWidth && "Invalid APInt Truncate request");

  // Can we just losslessly truncate it?
  if (isSignedIntN(width))
    return trunc(width);
  // If not, then just return the new limits.
  return isNegative() ? APInt::getSignedMinValue(width)
                      : APInt::getSignedMaxValue(width);
}

//  Zero extend to a new width.
APInt APInt::zext(unsigned width) const { return APInt(width, VAL); }

APInt APInt::sext(unsigned Width) const {
  return APInt(Width, SignExtend64(VAL, BitWidth));
}

APInt APInt::zextOrTrunc(unsigned width) const {
  if (BitWidth < width)
    return zext(width);
  if (BitWidth > width)
    return trunc(width);
  return *this;
}

APInt APInt::sextOrTrunc(unsigned width) const {
  if (BitWidth < width)
    return sext(width);
  if (BitWidth > width)
    return trunc(width);
  return *this;
}

void APInt::ashrInPlace(const APInt &shiftAmt) {
  ashrInPlace((unsigned)shiftAmt.getLimitedValue(BitWidth));
}

void APInt::lshrInPlace(const APInt &shiftAmt) {
  lshrInPlace((unsigned)shiftAmt.getLimitedValue(BitWidth));
}

APInt &APInt::operator<<=(const APInt &shiftAmt) {
  // It's undefined behavior in C to shift by BitWidth or greater.
  *this <<= (unsigned)shiftAmt.getLimitedValue(BitWidth);
  return *this;
}

// Calculate the rotate amount modulo the bit width.
static unsigned rotateModulo(unsigned BitWidth, const APInt &rotateAmt) {
  if (BitWidth == 0)
    return 0;
  unsigned rotBitWidth = rotateAmt.getBitWidth();
  APInt rot = rotateAmt;
  if (rotBitWidth < BitWidth) {
    // Extend the rotate APInt, so that the urem doesn't divide by 0.
    // e.g. APInt(1, 32) would give APInt(1, 0).
    rot = rotateAmt.zext(BitWidth);
  }
  rot = rot.urem(APInt(rot.getBitWidth(), BitWidth));
  return rot.getLimitedValue(BitWidth);
}

APInt APInt::rotl(const APInt &rotateAmt) const {
  return rotl(rotateModulo(BitWidth, rotateAmt));
}

APInt APInt::rotl(unsigned rotateAmt) const {
  if (BitWidth == 0)
    return *this;
  rotateAmt %= BitWidth;
  if (rotateAmt == 0)
    return *this;
  return shl(rotateAmt) | lshr(BitWidth - rotateAmt);
}

APInt APInt::rotr(const APInt &rotateAmt) const {
  return rotr(rotateModulo(BitWidth, rotateAmt));
}

APInt APInt::rotr(unsigned rotateAmt) const {
  if (BitWidth == 0)
    return *this;
  rotateAmt %= BitWidth;
  if (rotateAmt == 0)
    return *this;
  return lshr(rotateAmt) | shl(BitWidth - rotateAmt);
}

unsigned APInt::nearestLogBase2() const {
  if (BitWidth == 1)
    return VAL - 1;

  if (isZero())
    return UINT32_MAX;

  unsigned lg = logBase2();
  return lg + unsigned((*this)[lg - 1]);
}

/// \returns the multiplicative inverse of an odd APInt modulo 2^BitWidth.
APInt APInt::multiplicativeInverse() const {
  assert((*this)[0] &&
         "multiplicative inverse is only defined for odd numbers!");

  // Use Newton's method.
  APInt Factor = *this;
  APInt T;
  while (!(T = *this * Factor).isOne())
    Factor *= 2 - std::move(T);
  return Factor;
}

APInt APInt::udiv(const APInt &RHS) const {
  return APInt(BitWidth, VAL / RHS.VAL);
}

APInt APInt::udiv(uint64_t RHS) const { return APInt(BitWidth, VAL / RHS); }

APInt APInt::sdiv(const APInt &RHS) const {
  if (isNegative()) {
    if (RHS.isNegative())
      return (-(*this)).udiv(-RHS);
    return -((-(*this)).udiv(RHS));
  }
  if (RHS.isNegative())
    return -(this->udiv(-RHS));
  return this->udiv(RHS);
}

APInt APInt::sdiv(int64_t RHS) const {
  if (isNegative()) {
    if (RHS < 0)
      return (-(*this)).udiv(-RHS);
    return -((-(*this)).udiv(RHS));
  }
  if (RHS < 0)
    return -(this->udiv(-RHS));
  return this->udiv(RHS);
}

APInt APInt::urem(const APInt &RHS) const {
  return APInt(BitWidth, VAL % RHS.VAL);
}

uint64_t APInt::urem(uint64_t RHS) const { return VAL % RHS; }

APInt APInt::srem(const APInt &RHS) const {
  if (isNegative()) {
    if (RHS.isNegative())
      return -((-(*this)).urem(-RHS));
    return -((-(*this)).urem(RHS));
  }
  if (RHS.isNegative())
    return this->urem(-RHS);
  return this->urem(RHS);
}

int64_t APInt::srem(int64_t RHS) const {
  if (isNegative()) {
    if (RHS < 0)
      return -((-(*this)).urem(-RHS));
    return -((-(*this)).urem(RHS));
  }
  if (RHS < 0)
    return this->urem(-RHS);
  return this->urem(RHS);
}

void APInt::udivrem(const APInt &LHS, const APInt &RHS, APInt &Quotient,
                    APInt &Remainder) {
  unsigned BitWidth = LHS.BitWidth;
  uint64_t QuotVal = LHS.VAL / RHS.VAL;
  uint64_t RemVal = LHS.VAL % RHS.VAL;
  Quotient = APInt(BitWidth, QuotVal);
  Remainder = APInt(BitWidth, RemVal);
  return;
}

void APInt::udivrem(const APInt &LHS, uint64_t RHS, APInt &Quotient,
                    uint64_t &Remainder) {
  unsigned BitWidth = LHS.BitWidth;
  uint64_t QuotVal = LHS.VAL / RHS;
  Remainder = LHS.VAL % RHS;
  Quotient = APInt(BitWidth, QuotVal);
  return;
}

void APInt::sdivrem(const APInt &LHS, const APInt &RHS, APInt &Quotient,
                    APInt &Remainder) {
  if (LHS.isNegative()) {
    if (RHS.isNegative())
      APInt::udivrem(-LHS, -RHS, Quotient, Remainder);
    else {
      APInt::udivrem(-LHS, RHS, Quotient, Remainder);
      Quotient.negate();
    }
    Remainder.negate();
  } else if (RHS.isNegative()) {
    APInt::udivrem(LHS, -RHS, Quotient, Remainder);
    Quotient.negate();
  } else {
    APInt::udivrem(LHS, RHS, Quotient, Remainder);
  }
}

void APInt::sdivrem(const APInt &LHS, int64_t RHS, APInt &Quotient,
                    int64_t &Remainder) {
  uint64_t R = Remainder;
  if (LHS.isNegative()) {
    if (RHS < 0)
      APInt::udivrem(-LHS, -RHS, Quotient, R);
    else {
      APInt::udivrem(-LHS, RHS, Quotient, R);
      Quotient.negate();
    }
    R = -R;
  } else if (RHS < 0) {
    APInt::udivrem(LHS, -RHS, Quotient, R);
    Quotient.negate();
  } else {
    APInt::udivrem(LHS, RHS, Quotient, R);
  }
  Remainder = R;
}

APInt APInt::sadd_ov(const APInt &RHS, bool &Overflow) const {
  APInt Res = *this + RHS;
  Overflow = isNonNegative() == RHS.isNonNegative() &&
             Res.isNonNegative() != isNonNegative();
  return Res;
}

APInt APInt::uadd_ov(const APInt &RHS, bool &Overflow) const {
  APInt Res = *this + RHS;
  Overflow = Res.ult(RHS);
  return Res;
}

APInt APInt::ssub_ov(const APInt &RHS, bool &Overflow) const {
  APInt Res = *this - RHS;
  Overflow = isNonNegative() != RHS.isNonNegative() &&
             Res.isNonNegative() != isNonNegative();
  return Res;
}

APInt APInt::usub_ov(const APInt &RHS, bool &Overflow) const {
  APInt Res = *this - RHS;
  Overflow = Res.ugt(*this);
  return Res;
}

APInt APInt::sdiv_ov(const APInt &RHS, bool &Overflow) const {
  // MININT/-1  -->  overflow.
  Overflow = isMinSignedValue() && RHS.isAllOnes();
  return sdiv(RHS);
}

APInt APInt::smul_ov(const APInt &RHS, bool &Overflow) const {
  APInt Res = *this * RHS;

  if (RHS != 0)
    Overflow =
        Res.sdiv(RHS) != *this || (isMinSignedValue() && RHS.isAllOnes());
  else
    Overflow = false;
  return Res;
}

APInt APInt::umul_ov(const APInt &RHS, bool &Overflow) const {
  if (countl_zero() + RHS.countl_zero() + 2 <= BitWidth) {
    Overflow = true;
    return *this * RHS;
  }

  APInt Res = lshr(1) * RHS;
  Overflow = Res.isNegative();
  Res <<= 1;
  if ((*this)[0]) {
    Res += RHS;
    if (Res.ult(RHS))
      Overflow = true;
  }
  return Res;
}

APInt APInt::sshl_ov(const APInt &ShAmt, bool &Overflow) const {
  return sshl_ov(ShAmt.getLimitedValue(getBitWidth()), Overflow);
}

APInt APInt::sshl_ov(unsigned ShAmt, bool &Overflow) const {
  Overflow = ShAmt >= getBitWidth();
  if (Overflow)
    return APInt(BitWidth, 0);

  if (isNonNegative()) // Don't allow sign change.
    Overflow = ShAmt >= countl_zero();
  else
    Overflow = ShAmt >= countl_one();

  return *this << ShAmt;
}

APInt APInt::ushl_ov(const APInt &ShAmt, bool &Overflow) const {
  return ushl_ov(ShAmt.getLimitedValue(getBitWidth()), Overflow);
}

APInt APInt::ushl_ov(unsigned ShAmt, bool &Overflow) const {
  Overflow = ShAmt >= getBitWidth();
  if (Overflow)
    return APInt(BitWidth, 0);

  Overflow = ShAmt > countl_zero();

  return *this << ShAmt;
}

APInt APInt::sfloordiv_ov(const APInt &RHS, bool &Overflow) const {
  APInt quotient = sdiv_ov(RHS, Overflow);
  if ((quotient * RHS != *this) && (isNegative() != RHS.isNegative()))
    return quotient - 1;
  return quotient;
}

APInt APInt::sadd_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = sadd_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return isNegative() ? APInt::getSignedMinValue(BitWidth)
                      : APInt::getSignedMaxValue(BitWidth);
}

APInt APInt::uadd_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = uadd_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return APInt::getMaxValue(BitWidth);
}

APInt APInt::ssub_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = ssub_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return isNegative() ? APInt::getSignedMinValue(BitWidth)
                      : APInt::getSignedMaxValue(BitWidth);
}

APInt APInt::usub_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = usub_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return APInt(BitWidth, 0);
}

APInt APInt::smul_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = smul_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  // The result is negative if one and only one of inputs is negative.
  bool ResIsNegative = isNegative() ^ RHS.isNegative();

  return ResIsNegative ? APInt::getSignedMinValue(BitWidth)
                       : APInt::getSignedMaxValue(BitWidth);
}

APInt APInt::umul_sat(const APInt &RHS) const {
  bool Overflow;
  APInt Res = umul_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return APInt::getMaxValue(BitWidth);
}

APInt APInt::sshl_sat(const APInt &RHS) const {
  return sshl_sat(RHS.getLimitedValue(getBitWidth()));
}

APInt APInt::sshl_sat(unsigned RHS) const {
  bool Overflow;
  APInt Res = sshl_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return isNegative() ? APInt::getSignedMinValue(BitWidth)
                      : APInt::getSignedMaxValue(BitWidth);
}

APInt APInt::ushl_sat(const APInt &RHS) const {
  return ushl_sat(RHS.getLimitedValue(getBitWidth()));
}

APInt APInt::ushl_sat(unsigned RHS) const {
  bool Overflow;
  APInt Res = ushl_ov(RHS, Overflow);
  if (!Overflow)
    return Res;

  return APInt::getMaxValue(BitWidth);
}

std::optional<unsigned>
APIntOps::GetMostSignificantDifferentBit(const APInt &A, const APInt &B) {
  assert(A.getBitWidth() == B.getBitWidth() && "Must have the same bitwidth");
  if (A == B)
    return std::nullopt;
  return A.getBitWidth() - ((A ^ B).countl_zero() + 1);
}

APInt APIntOps::avgFloorS(const APInt &C1, const APInt &C2) {
  // Return floor((C1 + C2) / 2)
  return (C1 & C2) + (C1 ^ C2).ashr(1);
}

APInt APIntOps::avgFloorU(const APInt &C1, const APInt &C2) {
  // Return floor((C1 + C2) / 2)
  return (C1 & C2) + (C1 ^ C2).lshr(1);
}

APInt APIntOps::avgCeilS(const APInt &C1, const APInt &C2) {
  // Return ceil((C1 + C2) / 2)
  return (C1 | C2) - (C1 ^ C2).ashr(1);
}

APInt APIntOps::avgCeilU(const APInt &C1, const APInt &C2) {
  // Return ceil((C1 + C2) / 2)
  return (C1 | C2) - (C1 ^ C2).lshr(1);
}
