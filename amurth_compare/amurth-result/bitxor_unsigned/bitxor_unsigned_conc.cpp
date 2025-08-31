using A::APInt;
extern "C" APInt concrete_op(APInt a, APInt b) { return a ^ b; }