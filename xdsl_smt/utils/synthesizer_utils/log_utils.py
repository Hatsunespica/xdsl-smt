import logging
from typing import List
from pathlib import Path


def setup_loggers(output_dir: Path, verbose: int):
    """Sets up loggers to write INFO+DEBUG to one file, and only INFO to another."""
    logger = logging.getLogger(f"custom_logger_{output_dir}")
    logger.setLevel(logging.DEBUG)  # Capture all log levels
    formatter = logging.Formatter("%(message)s")

    # File Handler 1: info.log (Only INFO and higher)
    info_handler = logging.FileHandler(output_dir.joinpath("info.log"), mode="w")
    info_handler.setLevel(logging.INFO)
    info_handler.setFormatter(formatter)
    logger.addHandler(info_handler)
    if verbose > 0:
        # File Handler 2: debug.log (DEBUG and higher, including INFO)
        debug_handler = logging.FileHandler(output_dir.joinpath("debug.log"), mode="w")
        debug_handler.setLevel(logging.DEBUG)
        debug_handler.setFormatter(formatter)
        logger.addHandler(debug_handler)

    critical_handler = logging.FileHandler(
        output_dir.joinpath("critical.cpp"), mode="w", delay=True
    )
    critical_handler.setLevel(logging.CRITICAL)
    logger.addHandler(critical_handler)

    error_handler = logging.FileHandler(
        output_dir.joinpath("error.mlir"), mode="w", delay=True
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.addFilter(lambda record: record.levelno == logging.ERROR)
    logger.addHandler(error_handler)

    logger.info(f'LOG FILE FOR "{output_dir}"')
    return logger


def print_set_of_funcs_to_file(funcs: List[str], iter: int, path: Path):
    with open(path.joinpath(f"iter{iter}.mlir"), "w") as file:
        # file.write(
        #     f"Run: {c}_{rd}_{i}\nCost: {res.get_cost()}\nSound: {res.get_sound_prop()}\nUExact: {res.get_unsolved_exact_prop()}\nUDis: {res.get_unsolved_edit_dis_avg()}\n{res}\n"
        # )
        for f in funcs:
            file.write(f"{f}\n")
