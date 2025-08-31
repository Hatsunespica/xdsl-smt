using A::APInt;

extern "C" APInt minOr(APInt a, APInt b, APInt c, APInt d)
{
    APInt m = APInt::getOneBitSet(a.getBitWidth(), a.getBitWidth() - 1);
    APInt temp;
    APInt zero = APInt(a.getBitWidth(), 0);
    while (m.ne(zero))
    {
        if ((~a & c & m).ne(zero))
        {
            temp = (a | m) & -m;
            if (temp.ule(b))
            {
                a = temp;
                break;
            }
        }
        else if ((a & ~c & m).ne(zero))
        {
            temp = (c | m) & -m;
            if (temp.ule(d))
            {
                c = temp;
                break;
            }
        }
        m = m.lshr(1);
    }
    return a | c;
}

extern "C" APInt maxOr(APInt a, APInt b, APInt c, APInt d)
{
    APInt m = APInt::getOneBitSet(a.getBitWidth(), a.getBitWidth() - 1);
    APInt temp;
    APInt zero = APInt(a.getBitWidth(), 0);

    while (m.ne(zero))
    {
        if ((b & d & m).ne(zero))
        {
            temp = (b - m) | (m - 1);
            if (temp.uge(a))
            {
                b = temp;
                break;
            }
            temp = (d - m) | (m - 1);
            if (temp.uge(c))
            {
                d = temp;
                break;
            }
        }
        m = m.lshr(1);
    }
    return b | d;
}

extern "C" APInt minAND(APInt a, APInt b, APInt c, APInt d)
{
    APInt m = APInt::getOneBitSet(a.getBitWidth(), a.getBitWidth() - 1);
    APInt temp;
    APInt zero = APInt(a.getBitWidth(), 0);
    while (m.ne(zero))
    {
        if ((~a & ~c & m).ne(zero))
        {
            temp = (a | m) & -m;
            if (temp.ule(b))
            {
                a = temp;
                break;
            }
            temp = (c | m) & -m;
            if (temp.ule(d))
            {
                c = temp;
                break;
            }
        }
        m = m.lshr(1);
    }
    return a & c;
}

extern "C" APInt maxAND(APInt a, APInt b, APInt c, APInt d)
{
    APInt m = APInt::getOneBitSet(a.getBitWidth(), a.getBitWidth() - 1);
    APInt temp;
    APInt zero = APInt(a.getBitWidth(), 0);
    while (m.ne(zero))
    {
        if ((b & ~d & m).ne(zero))
        {
            temp = (b & ~m) | (m - 1);
            if (temp.uge(a))
            {
                b = temp;
                break;
            }
        }
        else if ((~b & d & m).ne(zero))
        {
            temp = (d & ~m) | (m - 1);
            if (temp.uge(c))
            {
                d = temp;
                break;
            }
        }
        m = m.lshr(1);
    }
    return b & d;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt zero = APInt(l1.getBitWidth(), 0);

    // Compute ~r2 and ~l2 (bitwise NOT)
    APInt notR2 = ~r2;
    APInt notL2 = ~l2;

    // First part: minAND(l1, r1, ~r2, ~l2)
    APInt part1 = minAND(l1, r1, notR2, notL2);

    // Compute ~r1 and ~l1 (bitwise NOT)
    APInt notR1 = ~r1;
    APInt notL1 = ~l1;

    // Second part: minAND(~r1, ~l1, l2, r2)
    APInt part2 = minAND(notR1, notL1, l2, r2);

    // Final result: maxOr(0, part1, 0, part2)
    return maxOr(zero, part1, zero, part2);
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt zero = APInt(l1.getBitWidth(), 0);

    // Compute ~r1 and ~l1 (bitwise NOT)
    APInt notR1 = ~r1;
    APInt notL1 = ~l1;

    // First part: minOr(~r1, ~l1, l2, r2)
    APInt part1 = minOr(notR1, notL1, l2, r2);

    // Compute ~r2 and ~l2 (bitwise NOT)
    APInt notR2 = ~r2;
    APInt notL2 = ~l2;

    // Second part: maxAND(l1, r1, ~r2, ~l2)
    APInt part2 = maxAND(l1, r1, notR2, notL2);

    // First maxOr result
    APInt result1 = maxOr(zero, part1, zero, part2);

    // Third part: maxAND(~r1, ~l1, l2, r2)
    APInt part3 = maxAND(notR1, notL1, l2, r2);

    // Fourth part: maxAND(l1, r1, ~r2, ~l2) (same as part2)
    APInt part4 = maxAND(l1, r1, notR2, notL2);

    // Second maxOr result
    APInt result2 = maxOr(zero, part3, zero, part4);

    // Final result: maxAND(0, result1, 0, result2)
    return maxAND(zero, result1, zero, result2);
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
