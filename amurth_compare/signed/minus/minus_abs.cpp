using A::APInt;

extern "C" APInt max(APInt a, APInt b)
{
    if (a.sgt(b)) // signed greater than
        return a;
    else
        return b;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: (l1 - 1) - r2
    APInt one = APInt(l1.getBitWidth(), 1);
    return (l1 - one) - r2;
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: max(r1 - l2, r1 - r2)
    APInt sub1 = r1 - l2;
    APInt sub2 = r1 - r2;
    return max(sub1, sub2);
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
