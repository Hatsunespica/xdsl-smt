from xdsl_smt.cli.synth_transfer import run
from os import path, environ
import pandas as pd
from math import nan
from multiprocessing import Pool
from random import randint
from io import StringIO
import telebot

# vals that xuanyu sugessted
NUM_PROGS = 100
NUM_ITERS = 20
NUM_ROUNDS = 1000
COND_LEN = 10
SOL_SIZE = 0
NUM_ABD_P = 30
BWIDTH = 4
WEIGHT_DSL = True

# something faster
# NUM_PROGS = 25
# NUM_ITERS = 2
# NUM_ROUNDS = 2
# COND_LEN = 15
# SOL_SIZE = 0
# NUM_ABD_P = 10
# BWIDTH = 4
# WEIGHT_DSL = True


def synth_run(args: tuple[str, str, str, int]) -> dict[str, float | str]:
    func_name = args[0]
    domain = args[1]
    fname = args[2]
    seed = args[3]

    res = run(
        num_programs=NUM_PROGS,
        num_iters=NUM_ITERS,
        total_rounds=NUM_ROUNDS,
        condition_length=COND_LEN,
        solution_size=SOL_SIZE,
        num_abd_procs=NUM_ABD_P,
        bitwidth=BWIDTH,
        weighted_dsl=WEIGHT_DSL,
        random_seed=seed,
        transfer_functions=fname,
    )

    sound_prop = nan if res is None else res.get_sound_prop() * 100
    exact_prop = nan if res is None else res.get_exact_prop() * 100

    return {
        "Domain": domain,
        "Function": func_name,
        "Sound Proportion": sound_prop,
        "Exact Proportion": exact_prop,
        "Seed": seed,
    }


def send_resuts(df: pd.DataFrame) -> None:
    try:
        bot_token = environ["TG_BOT_TOKEN"]
        chat_id = environ["TG_CHAT_ID"]
        bot = telebot.TeleBot(bot_token)

        buf = StringIO()
        df.to_csv(buf)
        buf.seek(0)
        buf.name = "data.csv"
        bot.send_document(chat_id, buf)
    except Exception as e:
        print(f"tried to send date via telegram but ran into an exception:\n{e}")
        df.to_csv("data.csv")


def main() -> None:
    # TODO a csv for all of the params
    # and a seperate csv for synthed results

    seed = randint(1, 1_000_000)

    start_dir = path.join("tests", "synth")
    xfer_funcs = {
        ("KnownBits", "Add"): "knownBitsAdd.mlir",
        ("KnownBits", "And"): "knownBitsAnd.mlir",
        ("KnownBits", "Ashr"): "knownBitsAshr.mlir",
        ("KnownBits", "Lshr"): "knownBitsLshr.mlir",
        ("KnownBits", "Mods"): "knownBitsMods.mlir",
        ("KnownBits", "Modu"): "knownBitsModu.mlir",
        ("KnownBits", "Mul"): "knownBitsMul.mlir",
        ("KnownBits", "Or"): "knownBitsOr.mlir",
        ("KnownBits", "Sdiv"): "knownBitsSdiv.mlir",
        ("KnownBits", "Shl"): "knownBitsShl.mlir",
        ("KnownBits", "Udiv"): "knownBitsUdiv.mlir",
        ("KnownBits", "Xor"): "knownBitsXor.mlir",
        ("ConstantRange", "Add"): "integerRangeAdd.mlir",
        ("ConstantRange", "And"): "integerRangeAnd.mlir",
        ("ConstantRange", "Ashr"): "integerRangeAshr.mlir",
        ("ConstantRange", "Lshr"): "integerRangeLshr.mlir",
        ("ConstantRange", "Mods"): "integerRangeMods.mlir",
        ("ConstantRange", "Modu"): "integerRangeModu.mlir",
        ("ConstantRange", "Mul"): "integerRangeMul.mlir",
        ("ConstantRange", "Or"): "integerRangeOr.mlir",
        ("ConstantRange", "Sdiv"): "integerRangeSdiv.mlir",
        ("ConstantRange", "Shl"): "integerRangeShl.mlir",
        ("ConstantRange", "Udiv"): "integerRangeUdiv.mlir",
        ("ConstantRange", "Xor"): "integerRangeXor.mlir",
    }

    def getPath(x: str) -> str:
        return "integerRange" if x == "ConstantRange" else "knownBits"

    xfer_funcs = {
        k: path.join(start_dir, getPath(k[0]), v) for k, v in xfer_funcs.items()
    }

    inputs = [
        (func_name, domain_name, xfer_func_fname, seed)
        for (domain_name, func_name), xfer_func_fname in xfer_funcs.items()
    ]

    with Pool() as p:
        data = p.map(synth_run, inputs)

    df = pd.DataFrame(data)
    send_resuts(df)
    print(df)


if __name__ == "__main__":
    main()
