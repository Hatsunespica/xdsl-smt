# this is a temporary place to have unit tests for the eval engine
# these should be turned into llvm-lit tests and moved to the tests dir
# run these tests via `python -m xdsl_smt.eval_engine.tester`
# TODO test at different bitwidths

from typing import NamedTuple
from xdsl_smt.eval_engine.eval import eval_transfer_func, AbstractDomain, setup_eval


class TestInput(NamedTuple):
    min_bw: int
    max_bw: int
    concrete_op: str
    op_constraint: str | None
    domain: AbstractDomain
    functions: list[tuple[str, str]]
    expected_outputs: list[str]


cnc_or = 'extern "C" APInt concrete_op(APInt a, APInt b) { return a|b; }'
cnc_add = 'extern "C" APInt concrete_op(APInt a, APInt b) { return a+b; }'
cnc_sub = 'extern "C" APInt concrete_op(APInt a, APInt b) { return a-b; }'
cnc_xor = 'extern "C" APInt concrete_op(APInt a, APInt b) { return a^b; }'
cnc_and = 'extern "C" APInt concrete_op(APInt a, APInt b) { return a&b; }'
cnc_udiv = 'extern "C" APInt concrete_op(APInt a, APInt b) {return a.udiv(b);}'
cnc_urem = 'extern "C" APInt concrete_op(APInt a, APInt b) {return a.urem(b);}'
cnc_umin = 'extern "C" APInt concrete_op(APInt a,APInt b) {return APIntOps::umin(a,b);}'
cnc_umax = 'extern "C" APInt concrete_op(APInt a,APInt b) {return APIntOps::umax(a,b);}'

add_nsw_op_constraint = """
extern "C" bool op_constraint(APInt a, APInt b) {
  bool f;
  a.uadd_ov(b, f);
  return !f;
}
"""

kb_and = (
    "kb_and",
    """
extern "C" Vec<2> kb_and(const Vec<2> arg0, const Vec<2> arg1) {
  APInt res_0 = arg0[0] | arg1[0];
  APInt res_1 = arg0[1] & arg1[1];
  return {res_0, res_1};
}
""",
)

kb_or = (
    "kb_or",
    """
extern "C" Vec<2> kb_or(const Vec<2> arg0, const Vec<2> arg1) {
  APInt res_0 = arg0[0] & arg1[0];
  APInt res_1 = arg0[1] | arg1[1];
  return {res_0, res_1};
}
""",
)

kb_xor = (
    "kb_xor",
    """
extern "C" Vec<2> kb_xor(const Vec<2> arg0, const Vec<2> arg1) {
  APInt res_0 = (arg0[0] & arg1[0]) | (arg0[1] & arg1[1]);
  APInt res_1 = (arg0[0] & arg1[1]) | (arg0[1] & arg1[0]);
  return {res_0, res_1};
}
""",
)

ucr_add = (
    "ucr_add",
    """
extern "C" Vec<2> ucr_add(const Vec<2> arg0, const Vec<2> arg1) {
  bool res0_ov;
  bool res1_ov;
  APInt res0 = arg0[0].uadd_ov(arg1[0], res0_ov);
  APInt res1 = arg0[1].uadd_ov(arg1[1], res1_ov);
  if (res0.ugt(res1) || (res0_ov ^ res1_ov))
    return {APInt::getMinValue(arg0[0].getBitWidth()),
            APInt::getMaxValue(arg0[0].getBitWidth())};
  return {res0, res1};
}
""",
)

ucr_sub = (
    "ucr_sub",
    """
extern "C" Vec<2> ucr_sub(const Vec<2> arg0, const Vec<2> arg1) {
  bool res0_ov;
  bool res1_ov;
  APInt res0 = arg0[0].usub_ov(arg1[1], res0_ov);
  APInt res1 = arg0[1].usub_ov(arg1[0], res1_ov);
  if (res0.ugt(res1) || (res0_ov ^ res1_ov))
    return {APInt::getMinValue(arg0[0].getBitWidth()),
            APInt::getMaxValue(arg0[0].getBitWidth())};
  return {res0, res1};
}
""",
)

scr_add = (
    "scr_add",
    """
extern "C" Vec<2> scr_add(const Vec<2> arg0, const Vec<2> arg1) {
  bool res0_ov;
  bool res1_ov;
  APInt res0 = arg0[0].sadd_ov(arg1[0], res0_ov);
  APInt res1 = arg0[1].sadd_ov(arg1[1], res1_ov);
  if (res0.sgt(res1) || (res0_ov ^ res1_ov))
    return {APInt::getSignedMinValue(arg0[0].getBitWidth()),
            APInt::getSignedMaxValue(arg0[0].getBitWidth())};
  return {res0, res1};
}
""",
)

im_add_nsw = (
    "im_add_nsw",
    """
const static unsigned int N = 6;
extern "C" Vec<N> im_add_nsw(const Vec<N> &lhs, const Vec<N> &rhs) {
  const unsigned int bw = lhs[0].getBitWidth();
  const APInt lhs_p = IM::prod(lhs);
  const APInt rhs_p = IM::prod(rhs);
  const APInt lhs_crt = IM::crt(lhs, lhs_p);
  const APInt rhs_crt = IM::crt(rhs, rhs_p);

  bool of = false;
  const APInt crt_sum = lhs_crt.uadd_ov(rhs_crt, of);
  if (of)
    return IM::bottom<N>(bw);

  crt_sum.uadd_ov(lhs_p, of);
  Vec<N> small_lhs = of ? IM::fromConcrete<N>(lhs_crt) : lhs;
  crt_sum.uadd_ov(rhs_p, of);
  Vec<N> small_rhs = of ? IM::fromConcrete<N>(rhs_crt) : rhs;

  Vec<N> x(bw);
  for (unsigned int i = 0; i < N; ++i)
    if (IM::primes[i] > A::APInt::getMaxValue(bw).getZExtValue())
      x[i] = 0;
    else if (small_lhs[i] != IM::primes[i] && small_rhs[i] != IM::primes[i])
      x[i] = (small_lhs[i] + small_rhs[i]).urem(IM::primes[i]);
    else
      x[i] = IM::primes[i];

  return x;
}
          """,
)


def test(input: TestInput) -> None:
    names, srcs = zip(*input.functions)
    helpers = (
        [input.concrete_op]
        if input.op_constraint is None
        else [input.concrete_op, input.op_constraint]
    )

    data_dir = setup_eval(
        input.domain, input.max_bw, input.min_bw, None, "\n".join(helpers)
    )

    results = eval_transfer_func(
        data_dir, list(names), list(srcs), [], [], helpers, input.domain
    )

    def normalize(s: str) -> str:
        return "\n".join([x.strip() for x in str(s).split("\n")]).strip()

    for n, r, e in zip(names, results, input.expected_outputs):
        if normalize(str(r)) != normalize(e):
            print("Unit test failure:\n")
            print(f"Abstract domain: {input.domain}")
            print(f"Concrete function:\n{input.concrete_op}")
            print(f"Failed function source name: {n}")
            print(f"Expected:\n{normalize(e)}")
            print(f"Got:\n{normalize(str(r))}")
            print("===================================================================")


kb_or_test = TestInput(
    1,
    4,
    cnc_or,
    None,
    AbstractDomain.KnownBits,
    [kb_xor, kb_and, kb_or],
    [
        """
bw: 1  all: 9     s: 8     e: 6     uall: 6     us: 5     ue: 3     dis: 4     udis: 4     bdis: 6     sdis: 3
bw: 2  all: 81    s: 64    e: 36    uall: 72    us: 55    ue: 27    dis: 72    udis: 72    bdis: 108   sdis: 60
bw: 3  all: 729   s: 512   e: 216   uall: 702   us: 485   ue: 189   dis: 972   udis: 972   bdis: 1458  sdis: 882
bw: 4  all: 6561  s: 4096  e: 1296  uall: 6480  us: 4015  ue: 1215  dis: 11664 udis: 11664 bdis: 17496 sdis: 11352
        """,
        """
bw: 1  all: 9     s: 5     e: 3     uall: 6     us: 4     ue: 2     dis: 8     udis: 6     bdis: 6     sdis: 4
bw: 2  all: 81    s: 25    e: 9     uall: 72    us: 24    ue: 8     dis: 144   udis: 132   bdis: 108   sdis: 88
bw: 3  all: 729   s: 125   e: 27    uall: 702   us: 124   ue: 26    dis: 1944  udis: 1890  bdis: 1458  sdis: 1308
bw: 4  all: 6561  s: 625   e: 81    uall: 6480  us: 624   ue: 80    dis: 23328 udis: 23112 bdis: 17496 sdis: 16496
        """,
        """
bw: 1  all: 9     s: 9     e: 9     uall: 6     us: 6     ue: 6     dis: 0     udis: 0     bdis: 6     sdis: 0
bw: 2  all: 81    s: 81    e: 81    uall: 72    us: 72    ue: 72    dis: 0     udis: 0     bdis: 108   sdis: 0
bw: 3  all: 729   s: 729   e: 729   uall: 702   us: 702   ue: 702   dis: 0     udis: 0     bdis: 1458  sdis: 0
bw: 4  all: 6561  s: 6561  e: 6561  uall: 6480  us: 6480  ue: 6480  dis: 0     udis: 0     bdis: 17496 sdis: 0
        """,
    ],
)

kb_and_test = TestInput(
    1,
    4,
    cnc_and,
    None,
    AbstractDomain.KnownBits,
    [kb_xor, kb_and, kb_or],
    [
        """
bw: 1  all: 9     s: 6     e: 4     uall: 6     us: 3     ue: 1     dis: 8     udis: 8     bdis: 6     sdis: 5
bw: 2  all: 81    s: 36    e: 16    uall: 72    us: 27    ue: 7     dis: 144   udis: 144   bdis: 108   sdis: 96
bw: 3  all: 729   s: 216   e: 64    uall: 702   us: 189   ue: 37    dis: 1944  udis: 1944  bdis: 1458  sdis: 1350
bw: 4  all: 6561  s: 1296  e: 256   uall: 6480  us: 1215  ue: 175   dis: 23328 udis: 23328 bdis: 17496 sdis: 16632
        """,
        """
bw: 1  all: 9     s: 9     e: 9     uall: 6     us: 6     ue: 6     dis: 0     udis: 0     bdis: 6     sdis: 0
bw: 2  all: 81    s: 81    e: 81    uall: 72    us: 72    ue: 72    dis: 0     udis: 0     bdis: 108   sdis: 0
bw: 3  all: 729   s: 729   e: 729   uall: 702   us: 702   ue: 702   dis: 0     udis: 0     bdis: 1458  sdis: 0
bw: 4  all: 6561  s: 6561  e: 6561  uall: 6480  us: 6480  ue: 6480  dis: 0     udis: 0     bdis: 17496 sdis: 0
        """,
        """
bw: 1  all: 9     s: 5     e: 3     uall: 6     us: 4     ue: 2     dis: 8     udis: 6     bdis: 6     sdis: 4
bw: 2  all: 81    s: 25    e: 9     uall: 72    us: 24    ue: 8     dis: 144   udis: 132   bdis: 108   sdis: 88
bw: 3  all: 729   s: 125   e: 27    uall: 702   us: 124   ue: 26    dis: 1944  udis: 1890  bdis: 1458  sdis: 1308
bw: 4  all: 6561  s: 625   e: 81    uall: 6480  us: 624   ue: 80    dis: 23328 udis: 23112 bdis: 17496 sdis: 16496
        """,
    ],
)

kb_xor_test = TestInput(
    1,
    4,
    cnc_xor,
    None,
    AbstractDomain.KnownBits,
    [kb_xor, kb_and, kb_or],
    [
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 81    s: 81    e: 81    uall: 56    us: 56    ue: 56    dis: 0     udis: 0     bdis: 72    sdis: 0
bw: 3  all: 729   s: 729   e: 729   uall: 604   us: 604   ue: 604   dis: 0     udis: 0     bdis: 972   sdis: 0
bw: 4  all: 6561  s: 6561  e: 6561  uall: 5936  us: 5936  ue: 5936  dis: 0     udis: 0     bdis: 11664 sdis: 0
        """,
        """
bw: 1  all: 9     s: 4     e: 4     uall: 4     us: 1     ue: 1     dis: 8     udis: 6     bdis: 4     sdis: 3
bw: 2  all: 81    s: 16    e: 16    uall: 56    us: 7     ue: 7     dis: 144   udis: 124   bdis: 72    sdis: 64
bw: 3  all: 729   s: 64    e: 64    uall: 604   us: 37    ue: 37    dis: 1944  udis: 1794  bdis: 972   sdis: 924
bw: 4  all: 6561  s: 256   e: 256   uall: 5936  us: 175   ue: 175   dis: 23328 udis: 22328 bdis: 11664 sdis: 11408
        """,
        """
bw: 1  all: 9     s: 6     e: 6     uall: 4     us: 3     ue: 3     dis: 4     udis: 2     bdis: 4     sdis: 1
bw: 2  all: 81    s: 36    e: 36    uall: 56    us: 27    ue: 27    dis: 72    udis: 52    bdis: 72    sdis: 36
bw: 3  all: 729   s: 216   e: 216   uall: 604   us: 189   ue: 189   dis: 972   udis: 822   bdis: 972   sdis: 648
bw: 4  all: 6561  s: 1296  e: 1296  uall: 5936  us: 1215  ue: 1215  dis: 11664 udis: 10664 bdis: 11664 sdis: 9072
        """,
    ],
)

kb_add_test = TestInput(
    1,
    4,
    cnc_add,
    None,
    AbstractDomain.KnownBits,
    [kb_xor, kb_and, kb_or],
    [
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 81    s: 65    e: 65    uall: 44    us: 40    ue: 40    dis: 20    udis: 8     bdis: 60    sdis: 8
bw: 3  all: 729   s: 425   e: 425   uall: 436   us: 300   ue: 300   dis: 440   udis: 248   bdis: 708   sdis: 228
bw: 4  all: 6561  s: 2625  e: 2625  uall: 4220  us: 2000  ue: 2000  dis: 6620  udis: 4328  bdis: 7692  sdis: 3892
        """,
        """
bw: 1  all: 9     s: 4     e: 4     uall: 4     us: 1     ue: 1     dis: 8     udis: 6     bdis: 4     sdis: 3
bw: 2  all: 81    s: 13    e: 13    uall: 44    us: 4     ue: 4     dis: 134   udis: 102   bdis: 60    sdis: 55
bw: 3  all: 729   s: 40    e: 40    uall: 436   us: 13    ue: 13    dis: 1724  udis: 1310  bdis: 708   sdis: 690
bw: 4  all: 6561  s: 121   e: 121   uall: 4220  us: 40    ue: 40    dis: 20018 udis: 15358 bdis: 7692  sdis: 7634
        """,
        """
bw: 1  all: 9     s: 6     e: 6     uall: 4     us: 3     ue: 3     dis: 4     udis: 2     bdis: 4     sdis: 1
bw: 2  all: 81    s: 33    e: 33    uall: 44    us: 24    ue: 24    dis: 82    udis: 42    bdis: 60    sdis: 27
bw: 3  all: 729   s: 174   e: 174   uall: 436   us: 147   ue: 147   dis: 1192  udis: 690   bdis: 708   sdis: 444
bw: 4  all: 6561  s: 897   e: 897   uall: 4220  us: 816   ue: 816   dis: 14974 udis: 9554  bdis: 7692  sdis: 5850
        """,
    ],
)

ucr_add_test = TestInput(
    1,
    4,
    cnc_add,
    None,
    AbstractDomain.UConstRange,
    [ucr_add, ucr_sub],
    [
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 100   s: 100   e: 100   uall: 46    us: 46    ue: 46    dis: 0     udis: 0     bdis: 96    sdis: 0
bw: 3  all: 1296  s: 1296  e: 1296  uall: 532   us: 532   ue: 532   dis: 0     udis: 0     bdis: 2352  sdis: 0
bw: 4  all: 18496 s: 18496 e: 18496 uall: 6920  us: 6920  ue: 6920  dis: 0     udis: 0     bdis: 63648 sdis: 0
        """,
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 100   s: 71    e: 59    uall: 46    us: 29    ue: 17    dis: 88    udis: 71    bdis: 96    sdis: 58
bw: 3  all: 1296  s: 839   e: 636   uall: 532   us: 278   ue: 75    dis: 2620  udis: 1950  bdis: 2352  sdis: 1994
bw: 4  all: 18496 s: 11951 e: 8906  uall: 6920  us: 3420  ue: 375   dis: 75432 udis: 53340 bdis: 63648 sdis: 59948
        """,
    ],
)

ucr_sub_test = TestInput(
    1,
    4,
    cnc_sub,
    None,
    AbstractDomain.UConstRange,
    [ucr_sub, ucr_add],
    [
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 100   s: 100   e: 100   uall: 46    us: 46    ue: 46    dis: 0     udis: 0     bdis: 96    sdis: 0
bw: 3  all: 1296  s: 1296  e: 1296  uall: 532   us: 532   ue: 532   dis: 0     udis: 0     bdis: 2352  sdis: 0
bw: 4  all: 18496 s: 18496 e: 18496 uall: 6920  us: 6920  ue: 6920  dis: 0     udis: 0     bdis: 63648 sdis: 0
        """,
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 100   s: 71    e: 59    uall: 46    us: 29    ue: 17    dis: 88    udis: 71    bdis: 96    sdis: 58
bw: 3  all: 1296  s: 839   e: 636   uall: 532   us: 278   ue: 75    dis: 2620  udis: 1950  bdis: 2352  sdis: 1994
bw: 4  all: 18496 s: 11951 e: 8906  uall: 6920  us: 3420  ue: 375   dis: 75432 udis: 53340 bdis: 63648 sdis: 59948
        """,
    ],
)

scr_add_test = TestInput(
    1,
    4,
    cnc_add,
    None,
    AbstractDomain.SConstRange,
    [scr_add],
    [
        """
bw: 1  all: 9     s: 9     e: 9     uall: 4     us: 4     ue: 4     dis: 0     udis: 0     bdis: 4     sdis: 0
bw: 2  all: 100   s: 100   e: 100   uall: 47    us: 47    ue: 47    dis: 0     udis: 0     bdis: 97    sdis: 0
bw: 3  all: 1296  s: 1296  e: 1296  uall: 580   us: 580   ue: 580   dis: 0     udis: 0     bdis: 2452  sdis: 0
bw: 4  all: 18496 s: 18496 e: 18496 uall: 7872  us: 7872  ue: 7872  dis: 0     udis: 0     bdis: 68016 sdis: 0
        """,
    ],
)

im_add_nsw_test = TestInput(
    4,
    4,
    cnc_add,
    add_nsw_op_constraint,
    AbstractDomain.IntegerModulo,
    [im_add_nsw],
    [
        """
bw: 4  all: 2971  s: 2971  e: 2971  uall: 2182  us: 2182  ue: 2182  dis: 0     udis: 0     bdis: 6964  sdis: 0
        """,
    ],
)


if __name__ == "__main__":
    test(kb_or_test)
    test(kb_and_test)
    test(kb_xor_test)
    test(kb_add_test)
    test(ucr_add_test)
    test(ucr_sub_test)
    test(scr_add_test)
    test(im_add_nsw_test)
