using A::APInt;

extern "C" Vec<2> amurth_tf(Vec<2> a, Vec<2> b)
{
    bool res0_ov;
    bool res1_ov;
    APInt res0 = a[0].uadd_ov(b[0], res0_ov);
    APInt res1 = a[1].uadd_ov(b[1], res1_ov);
    if (res0.ugt(res1) || (res0_ov ^ res1_ov))
        return {APInt::getMinValue(a[0].getBitWidth()),
                APInt::getMaxValue(a[0].getBitWidth())};
    return {res0, res1};
}