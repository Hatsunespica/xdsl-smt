#include <algorithm>
#include <cmath>
#include <concepts>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <llvm/ADT/APInt.h>
#include <llvm/Support/KnownBits.h>
#include <vector>

#include "../test.cpp"

template <typename T>
concept APIntContainer = requires(T t) {
  typename T::value_type;
  requires std::same_as<typename T::value_type, uint8_t>;
  requires std::ranges::range<T>;
};

// TODO provied hashing and ordering func for llvm APInts
// TODO switch between signed and unsigned ops when needed
// TODO use u8's instead of apints when possible for speed and ease
// enum TransferResult { GOOD, NOT_SOUND, NOT_PREC, NEITHER };

void print_abst_range(const llvm::KnownBits &x) {
  for (uint32_t i = x.Zero.getBitWidth() - 1; i >= 0; --i) {
    const char bit = x.One[i] ? '1' : x.Zero[i] ? '0' : '?';
    printf("%c", bit);
  }

  if (x.isConstant())
    printf(" const %lu", x.getConstant().getZExtValue());

  if (x.isUnknown())
    printf(" (top)");

  printf("\n");
}

// TODO consider printing full/top if it is
void print_conc_range(const APIntContainer auto &x) {
  if (x.empty())
    printf("empty");

  for (llvm::APInt i : x)
    printf("%ld ", i.getZExtValue());

  puts("");
}

// TODO there's a faster way to this but this works for now
// would also be nice if this moved up the lattice as the loops progressed
std::vector<llvm::KnownBits> const enum_abst_vals(const uint32_t bitwidth) {
  std::vector<llvm::KnownBits> ret;
  const llvm::APInt max = llvm::APInt::getMaxValue(bitwidth);
  for (uint64_t i = 0; i <= max.getZExtValue(); ++i) {
    for (uint64_t j = 0; j <= max.getZExtValue(); ++j) {
      auto x = llvm::KnownBits(bitwidth);
      x.One = i;
      x.Zero = j;

      if (!x.hasConflict())
        ret.push_back(x);
    }
  }

  return ret;
}

// TODO return a generic container based on what the caller asks for
// TODO there's a faster way to this but this works for now
std::vector<uint8_t> const to_concrete(const llvm::KnownBits &x) {
  std::vector<uint8_t> ret;
  const llvm::APInt min = llvm::APInt::getZero(x.Zero.getBitWidth());
  const llvm::APInt max = llvm::APInt::getMaxValue(x.Zero.getBitWidth());

  for (auto i = min;; ++i) {

    if (!x.Zero.intersects(i) && !x.One.intersects(~i))
      ret.push_back((unsigned char)i.getZExtValue());

    if (i == max)
      break;
  }

  return ret;
}

llvm::KnownBits const to_abstract(const APIntContainer auto &conc_vals) {
  auto ret = llvm::KnownBits::makeConstant(conc_vals[0]);

  for (auto x : conc_vals) {
    ret = ret.intersectWith(llvm::KnownBits::makeConstant(x));
  }

  return ret;
}

// TODO be able to return generic std container
// TODO have some automated check for UB?
std::vector<uint8_t> const
concrete_op(const APIntContainer auto &lhss, const APIntContainer auto &rhss,
            uint8_t (*op)(const uint8_t, const uint8_t)) {
  auto ret = std::vector<uint8_t>();

  for (auto lhs : lhss)
    for (auto rhs : rhss)
      ret.push_back(op(lhs, rhs));

  return ret;
}

// TODO make case enum
unsigned int compare(std::vector<uint8_t> &approx,
                     std::vector<uint8_t> &exact) {

  bool sound = true;
  bool prec = true;
  std::sort(approx.begin(), approx.end());
  std::sort(exact.begin(), exact.end());

  std::vector<uint64_t> approx_m_exact;
  std::set_difference(approx.begin(), approx.end(), exact.begin(), exact.end(),
                      std::back_inserter(approx_m_exact));

  if (!approx_m_exact.empty())
    prec = false;

  std::vector<uint64_t> exact_m_approx;
  std::set_difference(exact.begin(), exact.end(), approx.begin(), approx.end(),
                      std::back_inserter(exact_m_approx));

  if (!exact_m_approx.empty())
    sound = false;

  if (!sound && !prec)
    return 0;

  if (!sound)
    return 1;

  if (!prec)
    return 2;

  return 3;
}

std::tuple<llvm::APInt, llvm::APInt>
ANDImpl(std::tuple<llvm::APInt, llvm::APInt> arg0,
        std::tuple<llvm::APInt, llvm::APInt> arg1);

llvm::KnownBits test_f(const llvm::KnownBits &lhs, const llvm::KnownBits &rhs) {
  const auto [zero, one] =
      ANDImpl(std::tuple(lhs.Zero, lhs.One), std::tuple(rhs.Zero, rhs.One));

  llvm::KnownBits res;

  res.Zero = zero;
  res.One = one;

  return res;
}

int main() {
  const size_t bitwidth = 4;

  std::vector<int> cases = {0, 0, 0, 0};
  long long total_cases = 0;

  for (auto lhs : enum_abst_vals(bitwidth)) {
    for (auto rhs : enum_abst_vals(bitwidth)) {
      auto transfer_vals = to_concrete(test_f(lhs, rhs));
      auto brute_vals = concrete_op(to_concrete(lhs), to_concrete(rhs),
                                    [](const uint8_t a, const uint8_t b) {
                                      return (unsigned char)(a + b);
                                    });

      const unsigned int caseNum = compare(transfer_vals, brute_vals);
      cases[caseNum]++;
      total_cases++;
    }
  }

  printf("Not sound or precise: %i\n", cases[0]);
  printf("Not sound:            %i\n", cases[1]);
  printf("Not precise:          %i\n", cases[2]);
  printf("Good:                 %i\n", cases[3]);
  printf("total tests:          %lld\n", total_cases);

  return 0;
}
