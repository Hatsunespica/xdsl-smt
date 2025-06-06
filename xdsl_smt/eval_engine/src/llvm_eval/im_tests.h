#include <optional>
#include <vector>

#include "../AbstVal.h"
#include "../warning_suppresor.h"
#include "common.h"

inline const IntegerModulo<6>
im_xfer_wrapper(const IntegerModulo<6> &lhs, const IntegerModulo<6> &_,
                const XferFn<std::nullopt_t> &fn) {
  (void)fn;
  return IntegerModulo<6>::bottom(lhs.bw());
}

const std::vector<
    std::tuple<std::string, std::optional<XferFn<std::nullopt_t>>>>
    IM_TESTS{
        {"Abds", std::nullopt},      {"Abdu", std::nullopt},
        {"Add", std::nullopt},       {"AddNsw", std::nullopt},
        {"AddNswNuw", std::nullopt}, {"AddNuw", std::nullopt},
        {"And", std::nullopt},       {"Ashr", std::nullopt},
        {"AshrExact", std::nullopt}, {"AvgCeilS", std::nullopt},
        {"AvgCeilU", std::nullopt},  {"AvgFloorS", std::nullopt},
        {"AvgFloorU", std::nullopt}, {"Lshr", std::nullopt},
        {"LshrExact", std::nullopt}, {"Mods", std::nullopt},
        {"Modu", std::nullopt},      {"Mul", std::nullopt},
        {"MulNsw", std::nullopt},    {"MulNswNuw", std::nullopt},
        {"MulNuw", std::nullopt},    {"Mulhs", std::nullopt},
        {"Mulhu", std::nullopt},     {"Or", std::nullopt},
        {"SaddSat", std::nullopt},   {"Sdiv", std::nullopt},
        {"SdivExact", std::nullopt}, {"Shl", std::nullopt},
        {"ShlNsw", std::nullopt},    {"ShlNswNuw", std::nullopt},
        {"ShlNuw", std::nullopt},    {"Smax", std::nullopt},
        {"Smin", std::nullopt},      {"SmulSat", std::nullopt},
        {"SshlSat", std::nullopt},   {"SsubSat", std::nullopt},
        {"Sub", std::nullopt},       {"SubNsw", std::nullopt},
        {"SubNswNuw", std::nullopt}, {"SubNuw", std::nullopt},
        {"UaddSat", std::nullopt},   {"Udiv", std::nullopt},
        {"UdivExact", std::nullopt}, {"Umax", std::nullopt},
        {"Umin", std::nullopt},      {"UmulSat", std::nullopt},
        {"UshlSat", std::nullopt},   {"UsubSat", std::nullopt},
        {"Xor", std::nullopt},
    };
