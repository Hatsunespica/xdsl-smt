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

extern "C" Vec<2> amurth_tf(Vec<2> a, Vec<2> b)
{
    APInt l1 = a[0];
    APInt r1 = a[1];
    APInt l2 = b[0];
    APInt r2 = b[1];
    APInt outl = minAND(l1, r1, l2, r2);
    APInt outr = maxAND(l1, r1, l2, r2);
    Vec<2> out = Vec<2>{outl, outr};
    return out;
}