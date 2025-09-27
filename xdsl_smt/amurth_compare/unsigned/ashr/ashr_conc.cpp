using A::APInt;
extern "C" APInt concrete_op(APInt a, APInt b) { return a.ashr(b); }

extern "C" bool op_constraint(APInt a, APInt b)
{
    return b.uge(0) && b.ule(a.getBitWidth());
}
