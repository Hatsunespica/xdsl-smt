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

extern "C" void intervalSSplit(APInt a, APInt b, APInt result[4])
{
    APInt zero = APInt(a.getBitWidth(), 0);
    APInt minusOne = APInt::getAllOnes(a.getBitWidth());

    // If interval [a, b] contains 0 (i.e., a <= 0 && 0 <= b)
    if (a.sle(zero) && zero.sle(b))
    {
        // Split into [a, -1] and [0, b]
        result[0] = a;
        result[1] = minusOne;
        result[2] = zero;
        result[3] = b;
    }
    else
    {
        // Otherwise, return the same interval twice: [a, b] and [a, b]
        result[0] = a;
        result[1] = b;
        result[2] = a;
        result[3] = b;
    }
}

extern "C" void Join(APInt newLeft, APInt newRight, APInt currentLeft, APInt currentRight, APInt result[2])
{
    // Update the result interval to include the new interval [newLeft, newRight]
    if (newLeft.slt(currentLeft))
        result[0] = newLeft;
    else
        result[0] = currentLeft;

    if (newRight.sgt(currentRight))
        result[1] = newRight;
    else
        result[1] = currentRight;
}

extern "C" void bitWiseTemplateWrapped_c(APInt a, APInt b, APInt c, APInt d, int bnd, APInt result[2])
{
    APInt s1[4];
    APInt s2[4];

    intervalSSplit(a, b, s1);
    intervalSSplit(c, d, s2);

    result[0] = s1[0];
    result[1] = s1[1];

    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            APInt a_0 = s1[i * 2];
            APInt b_0 = s1[(i * 2) + 1];
            APInt c_0 = s2[j * 2];
            APInt d_0 = s2[(j * 2) + 1];

            APInt minResult = minAND(a_0, b_0, c_0, d_0);
            APInt maxResult = maxAND(a_0, b_0, c_0, d_0);

            Join(minResult, maxResult, result[0], result[1], result);
        }
    }
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt out[2];
    bitWiseTemplateWrapped_c(l1, r1, l2, r2, 2, out);
    return out[0];
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt out[2];
    bitWiseTemplateWrapped_c(l1, r1, l2, r2, 2, out);
    return out[1];
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
