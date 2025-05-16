#include <iostream>
#include <optional>
#include <vector>

#include "../AbstVal.h"
#include "../warning_suppresor.h"
#include "common.h"

SUPPRESS_WARNINGS_BEGIN
#include "llvm/ADT/STLExtras.h"
SUPPRESS_WARNINGS_END

inline const IntegerModulo<6>
im_xfer_wrapper(const IntegerModulo<6> &lhs, const IntegerModulo<6> &_,
                const XferFn<std::nullopt_t> &fn) {
  (void)fn;
  return IntegerModulo<6>::bottom(lhs.bw());
}

inline const std::vector<Test<std::nullopt_t>> im_tests() {
  const std::vector<
      std::tuple<std::string, std::optional<XferFn<std::nullopt_t>>>>
      im_tests{
          {"and", std::nullopt},        {"or", std::nullopt},
          {"xor", std::nullopt},        {"add", std::nullopt},
          {"add nsw", std::nullopt},    {"add nuw", std::nullopt},
          {"add nsuw", std::nullopt},   {"sub", std::nullopt},
          {"sub nsw", std::nullopt},    {"sub nuw", std::nullopt},
          {"sub nsuw", std::nullopt},   {"umax", std::nullopt},
          {"umin", std::nullopt},       {"smax", std::nullopt},
          {"smin", std::nullopt},       {"abdu", std::nullopt},
          {"abds", std::nullopt},       {"udiv", std::nullopt},
          {"udiv exact", std::nullopt}, {"sdiv", std::nullopt},
          {"sdiv exact", std::nullopt}, {"urem", std::nullopt},
          {"srem", std::nullopt},       {"mul", std::nullopt},
          {"mul nsw", std::nullopt},    {"mul nuw", std::nullopt},
          {"mul nsuw", std::nullopt},   {"mulhs", std::nullopt},
          {"mulhu", std::nullopt},      {"shl", std::nullopt},
          {"shl nsw", std::nullopt},    {"shl nuw", std::nullopt},
          {"shl nsuw", std::nullopt},   {"lshr", std::nullopt},
          {"lshr exact", std::nullopt}, {"ashr", std::nullopt},
          {"ashr exact", std::nullopt}, {"avgfloors", std::nullopt},
          {"avgflooru", std::nullopt},  {"avgceils", std::nullopt},
          {"avgceilu", std::nullopt},   {"uadd sat", std::nullopt},
          {"usub sat", std::nullopt},   {"sadd sat", std::nullopt},
          {"ssub sat", std::nullopt},   {"umul sat", std::nullopt},
          {"smul sat", std::nullopt},   {"ushl sat", std::nullopt},
          {"sshl sat", std::nullopt},
      };

  if (tests.size() != im_tests.size()) {
    std::cerr << "Test size mismatch: " << tests.size() << " | "
              << im_tests.size() << "\n";
    exit(1);
  }

  std::vector<Test<std::nullopt_t>> v;
  for (const auto &[test, imTest] : llvm::zip(tests, im_tests)) {
    const auto &[tName, concFn, opConFn] = test;
    const auto &[imName, imOp] = imTest;
    if (tName != imName) {
      std::cerr << "Function name mismatch: " << tName << " | " << imName
                << "\n";
      exit(1);
    }
    v.emplace_back(tName, concFn, opConFn, imOp);
  }

  return v;
}
