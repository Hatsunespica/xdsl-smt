#include <functional>
#include <optional>
#include <string>

#include "../APInt.h"

typedef A::APInt (A::APInt::*ovFn)(const A::APInt &, bool &) const;
typedef std::function<const A::APInt(const A::APInt, const A::APInt)> concFn;
typedef std::function<bool(const A::APInt, const A::APInt)> opConFn;

template <typename D>
using XferFn = std::function<const D(const D &, const D &)>;

template <typename D>
using Test = std::tuple<std::string, concFn, std::optional<opConFn>,
                        std::optional<XferFn<D>>>;

template <typename D, typename D2>
using XferWrap =
    const std::function<const D(const D &, const D &, const XferFn<D2> &)>;

bool nonZeroRhs(const A::APInt &, const A::APInt &);
opConFn getNW(ovFn);
opConFn getNW(ovFn, ovFn);

extern const std::vector<std::tuple<std::string, concFn, std::optional<opConFn>>>
    tests;
