using A::APInt;

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // For signed left shift, we use l1 shifted left by l2
    // The .shl() method handles left shift operation (same as unsigned)
    return l1.shl(l2);
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // For signed left shift, we use r1 shifted left by l2
    // The .shl() method handles left shift operation (same as unsigned)
    return r1.shl(l2);
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
