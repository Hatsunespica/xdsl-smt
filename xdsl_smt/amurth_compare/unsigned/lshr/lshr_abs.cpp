using A::APInt;

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // For unsigned logical right shift, the original uses arithRShift on l1
    // Since this is unsigned, we use arithmetic right shift
    return l1.ashr(l2);
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // For unsigned logical right shift, the original uses bvrshiftN on r1
    // This should be logical right shift
    return r1.lshr(l2);
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
