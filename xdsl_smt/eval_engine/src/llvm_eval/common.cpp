#include "../APInt.h"

bool nonZeroRhs(const A::APInt &_, const A::APInt &rhs) { return !rhs == 0; }
