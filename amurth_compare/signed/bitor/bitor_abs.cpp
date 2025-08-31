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

extern "C" APInt smin(APInt a, APInt b)
{
    if (a.slt(b))
        return a;
    else
        return b;
}

extern "C" APInt absleft_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt zero = APInt(l1.getBitWidth(), 0);

    if ((l1.slt(zero) && r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return minOr(l1, r1, l2, r2);
    }
    else if ((l1.slt(zero) && r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        return l1;
    }
    else if ((l1.slt(zero) && r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        return minOr(l1, r1, l2, r2);
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return l2;
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        return smin(l1, l2);
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        APInt minusOne = APInt::getAllOnes(l1.getBitWidth());
        return minOr(l1, minusOne, l2, r2);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return minOr(l1, r1, l2, r2);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        APInt minusOne = APInt::getAllOnes(l1.getBitWidth());
        return minOr(l1, r1, l2, minusOne);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        return minOr(l1, r1, l2, r2);
    }

    // Default case (should not reach here)
    return zero;
}

extern "C" APInt absright_c(APInt l1, APInt r1, APInt l2, APInt r2)
{
    APInt zero = APInt(l1.getBitWidth(), 0);
    APInt minusOne = APInt::getAllOnes(l1.getBitWidth());

    if ((l1.slt(zero) && r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return maxOr(l1, r1, l2, r2);
    }
    else if ((l1.slt(zero) && r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        return minusOne;
    }
    else if ((l1.slt(zero) && r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        return maxOr(l1, r1, l2, r2);
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return minusOne;
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        return maxOr(l1, r1, zero, r2);
    }
    else if ((l1.slt(zero) && !r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        return maxOr(l1, r1, zero, r2);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && r2.slt(zero)))
    {
        return maxOr(l1, r1, l2, r2);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (l2.slt(zero) && !r2.slt(zero)))
    {
        return maxOr(zero, r1, l2, r2);
    }
    else if ((!l1.slt(zero) && !r1.slt(zero)) && (!l2.slt(zero) && !r2.slt(zero)))
    {
        return maxOr(l1, r1, l2, r2);
    }

    // Default case (should not reach here)
    return zero;
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
