using A::APInt;

extern "C" APInt min(APInt a, APInt b)
{
    if (a.ult(b)) // unsigned less than
        return a;
    else
        return b;
}

extern "C" APInt max(APInt a, APInt b)
{
    if (a.ugt(b)) // unsigned greater than
        return a;
    else
        return b;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: modularMinus(max(l2, l2), min(r1, l2))
    // Simplified: max(l2, l2) = l2, modularMinus = normal subtraction
    APInt maxVal = max(l2, l2); // This is just l2
    APInt minVal = min(r1, l2);
    return maxVal - minVal;
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: max(modularMinus(r1, l2), modularMinus(r1, r2))
    // Simplified: modularMinus = normal subtraction
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
