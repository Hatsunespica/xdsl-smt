#include <cassert>
#include <cstdint>

class [[nodiscard]] APInt {
public:
  static constexpr uint64_t WORDTYPE_MAX = ~uint64_t(0);
  static constexpr unsigned APINT_WORD_SIZE = sizeof(uint64_t);
  static constexpr unsigned APINT_BITS_PER_WORD = APINT_WORD_SIZE * 8;

  APInt(unsigned numBits, uint64_t val) : BitWidth(numBits) {
    assert(numBits > 0 && "numBits must be greater than 0");
    assert(numBits <= 64 && "numBits must not exceed 64");

    VAL = val;
    clearUnusedBits();
  }

private:
  unsigned BitWidth; ///< The number of bits in this APInt.
  uint64_t VAL;      ///< Used to store the <= 64 bits integer value.

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
};
