from pathlib import Path

# from io import StringIO

from xdsl_smt.eval_engine.eval import eval_transfer_func, AbstractDomain, setup_eval
from xdsl_smt.cli.synth_transfer import print_to_cpp, get_helper_funcs
from xdsl_smt.utils.synthesizer_utils.verifier_utils import verify_transfer_function

from xdsl.context import Context
from xdsl.parser import ModuleOp, Parser

from ..dialects.smt_dialect import SMTDialect
from ..dialects.smt_bitvector_dialect import SMTBitVectorDialect
from ..dialects.index_dialect import Index
from ..dialects.smt_utils_dialect import SMTUtilsDialect
from xdsl.dialects.builtin import Builtin
from xdsl.dialects.func import Func, FuncOp
from ..dialects.transfer import Transfer
from xdsl.dialects.arith import Arith
from xdsl.dialects.comb import Comb
from xdsl.dialects.hw import HW
# from xdsl_smt.dialects import smt_bitvector_dialect as smt_bv


ctx = Context()
ctx.load_dialect(Arith)
ctx.load_dialect(Builtin)
ctx.load_dialect(Func)
ctx.load_dialect(SMTDialect)
ctx.load_dialect(SMTBitVectorDialect)
ctx.load_dialect(SMTUtilsDialect)
ctx.load_dialect(Transfer)
ctx.load_dialect(Index)
ctx.load_dialect(Comb)
ctx.load_dialect(HW)


def get_fn(fp: str) -> tuple[FuncOp, list[FuncOp]]:
    with open(fp, "r") as f:
        fn = Parser(ctx, f.read(), f.name).parse_op()
        assert isinstance(fn, ModuleOp)

        fns = {x.sym_name.data: x for x in fn.ops if isinstance(x, FuncOp)}

        return fns["xfer_func"], list(fns.values())


def main():
    domain = AbstractDomain.KnownBits
    div_fnames = [
        (Path("div_errors/and_error.mlir"), Path("tests/synth/Operations/And.mlir")),
        (Path("div_errors/add_error.mlir"), Path("tests/synth/Operations/Add.mlir")),
        (
            Path("div_errors/avgflooru_error.mlir"),
            Path("tests/synth/Operations/AvgFloorU.mlir"),
        ),
        (Path("div_errors/mul_error.mlir"), Path("tests/synth/Operations/Mul.mlir")),
        (Path("div_errors/udiv_error.mlir"), Path("tests/synth/Operations/Udiv.mlir")),
        (
            Path("div_errors/udivexact_error.mlir"),
            Path("tests/synth/Operations/UdivExact.mlir"),
        ),
        (Path("div_errors/umax_error.mlir"), Path("tests/synth/Operations/Umax.mlir")),
    ]
    bit_fnames = [
        (Path("bit_errors/add_error.mlir"), Path("tests/synth/Operations/Add.mlir")),
        (Path("bit_errors/and_error.mlir"), Path("tests/synth/Operations/And.mlir")),
        (
            Path("bit_errors/avgflooru_error.mlir"),
            Path("tests/synth/Operations/AvgFloorU.mlir"),
        ),
        (Path("bit_errors/modu_error.mlir"), Path("tests/synth/Operations/Modu.mlir")),
        (Path("bit_errors/mods_error.mlir"), Path("tests/synth/Operations/Mods.mlir")),
        (Path("bit_errors/mul_error.mlir"), Path("tests/synth/Operations/Mul.mlir")),
        (Path("bit_errors/sdiv_error.mlir"), Path("tests/synth/Operations/Sdiv.mlir")),
        (Path("bit_errors/udiv_error.mlir"), Path("tests/synth/Operations/Udiv.mlir")),
        (
            Path("bit_errors/udivexact_error.mlir"),
            Path("tests/synth/Operations/UdivExact.mlir"),
        ),
        (Path("bit_errors/umax_error.mlir"), Path("tests/synth/Operations/Umax.mlir")),
    ]
    fnames = [
        (Path("add_error.mlir"), Path("tests/synth/Operations/Add.mlir")),
        (Path("avgflooru_error.mlir"), Path("tests/synth/Operations/AvgFloorU.mlir")),
        (Path("modu_error.mlir"), Path("tests/synth/Operations/Modu.mlir")),
        (Path("sdiv_error.mlir"), Path("tests/synth/Operations/Sdiv.mlir")),
        (Path("udivexact_error.mlir"), Path("tests/synth/Operations/UdivExact.mlir")),
        (Path("umax_error.mlir"), Path("tests/synth/Operations/Umax.mlir")),
    ]
    for xfer_fname, conc_fname in fnames:
        print("####################")
        print(conc_fname)
        _, h = get_helper_funcs(conc_fname, domain, False)
        helpers_cpp = h.to_cpp()
        xfer, xfer_helpers = get_fn(str(xfer_fname))
        code_str = [print_to_cpp(x) for x in xfer_helpers]
        data_dir = setup_eval(domain, 4, 1, None, "\n".join(helpers_cpp))

        # print("\n".join(code_str))

        eval_res = eval_transfer_func(
            data_dir, ["xfer_func"], code_str, [], [], helpers_cpp, domain
        )[0]

        xfer_helpers = list(
            filter(lambda x: x.sym_name.data != "xfer_func", xfer_helpers)
        )

        print("eval engine:")
        for pb in eval_res.per_bit:
            s = "" if pb.sounds == pb.all_cases else "not "
            print(f"\t{s}sound at bw {pb.bitwidth}")

        print("verifyer:")
        for i in range(1, 5):
            # try:
            s = verify_transfer_function(
                xfer, h.crt_func, h.items_to_print() + xfer_helpers, ctx, i, i
            )
            if s == 0:
                print(f"\tsound at bw {i}")
            else:
                print(f"\tnot sound at bw {s}")
    # except Exception as e:
    #     print(f"\texception at bw {i}: {e}")

    # # smt_ctx = smt_bv.SMTConversionCtx()
    # const_2 = smt_bv.ConstantOp.from_int_value(0, 8).res
    # const_10 = smt_bv.ConstantOp.from_int_value(10, 8).res
    # a = SetHighBitsOp(const_2, const_10)
    # print(a)
    # print(a.T)
    # # udiv = smt_bv.UDivOp(const_10.res, const_2.res)
    # sio = StringIO()
    # # udiv.print_expr_to_smtlib(sio, smt_ctx)
    # # print(udiv.verify())
    # print(sio.getvalue())


if __name__ == "__main__":
    main()
