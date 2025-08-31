using A::APInt;

extern "C" APInt min(APInt a, APInt b)
{
    if (a.slt(b)) // signed less than
        return a;
    else
        return b;
}

extern "C" APInt max(APInt a, APInt b)
{
    if (a.sgt(b)) // signed greater than
        return a;
    else
        return b;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: min(min(l2 * l1, r1 * r2), min(l2 * r1, r2 * l1))
    APInt prod1 = min(l2 * l1, r1 * r2);
    APInt prod2 = min(l2 * r1, r2 * l1);
    return min(prod1, prod2);
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: max(max(r2 * r1, l2 * l1), max(l2, l1) * min(r2, r1))
    APInt prod1 = max(r2 * r1, l2 * l1);
    APInt maxVal = max(l2, l1);
    APInt minVal = min(r2, r1);
    APInt prod2 = maxVal * minVal;
    return max(prod1, prod2);
}

extern "C" Vec<2> amurth_tf(Vec<2> a, Vec<2> b)
{
    APInt l1 = a[0];
    APInt r1 = a[1];
    APInt l2 = b[0];
    APInt r2 = b[1];
    APInt outl = absleft_c(l1, r1, l2, r2);
    APInt outr = absright_c(l1, r1, l2, r2);
    Vec<2> out = Vec<2>{outl, outr};
    return out;
}
