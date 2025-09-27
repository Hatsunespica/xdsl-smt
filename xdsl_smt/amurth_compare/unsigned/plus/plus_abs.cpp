using A::APInt;

extern "C" Vec<2> amurth_tf(Vec<2> a, Vec<2> b)
{
    APInt l1 = a[0];
    APInt r1 = a[1];
    APInt l2 = b[0];
    APInt r2 = b[1];
    APInt outl = l1 + l2;
    APInt outr = r1 + r2;
    Vec<2> out = Vec<2>{outl, outr};
    return out;
}
