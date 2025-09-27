using A::APInt;

// Helper functions for unsigned min/max
extern "C" APInt umin(APInt a, APInt b)
{
    return a.ult(b) ? a : b;
}

extern "C" APInt umax(APInt a, APInt b)
{
    return a.ugt(b) ? a : b;
}

// Use APInt's built-in overflow checker
extern "C" bool umul_overflow(APInt a, APInt b)
{
    bool overflow;
    a.umul_ov(b, overflow);
    return overflow;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Original: modularMul(l2, l1) -> l2 * l1
    return l2 * l1;
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    // Check for overflow first
    if (umul_overflow(r1, r2))
    {
        // Return maximum value (15 in original, but we'll use all ones for APInt)
        return APInt::getAllOnes(r1.getBitWidth());
    }
    else
    {
        // Original logic:
        // out_s95 = max(l2, r1);
        APInt out_s95 = umax(l2, r1);

        // _out0_s91 = modularMul(r2, r1); -> r2 * r1
        APInt _out0_s91 = r2 * r1;

        // out_s95_0 = max(r2, l1);
        APInt out_s95_0 = umax(r2, l1);

        // out_s93 = min(_out0_s91, out_s95_0);
        APInt out_s93 = umin(_out0_s91, out_s95_0);

        // _out0_s91_0 = modularMul(out_s95, out_s93); -> out_s95 * out_s93
        APInt _out0_s91_0 = out_s95 * out_s93;

        return _out0_s91_0;
    }
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
