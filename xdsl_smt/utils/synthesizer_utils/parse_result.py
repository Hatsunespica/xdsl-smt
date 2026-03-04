from xdsl_smt.utils.synthesizer_utils.compare_result import PerBitRes, EvalResult


RESULT_DELIMITER="======="
PER_BIT_RESULT_DELIMITER="------"

def parse_per_bit_result(text: str) -> list[PerBitRes]:
    lines = [line.strip() for line in text.splitlines() if line.strip()]

    # ---- shared header ----
    bitwidth = int(lines[0].split(": ")[1])
    total_cases = int(lines[1].split(": ")[1])
    total_unsolved = int(lines[2].split(": ")[1])
    base_dist = int(lines[3].split(": ")[1])  # still int in output

    results: list[PerBitRes] = []
    current = {}

    for line in lines[4:]:
        if line == "------":
            if current:
                results.append(
                    PerBitRes(
                        all_cases=total_cases,
                        bitwidth=bitwidth,
                        sounds=current["soundCases"],
                        exacts=current["exactCases"],
                        dist=current["distance"],              # int assigned to float field
                        base_dist=base_dist,                   # int assigned to float field
                        unsolved_cases=total_unsolved,
                        unsolved_exacts=current["unsolvedExactCases"],
                        sound_dist=current["soundDistance"],   # int assigned to float field
                    )
                )
                current = {}
            continue

        key, value = line.split(" = ")
        current[key] = int(value)

    return results

def parse_cache_name(full_text:str)->str:
    """
    Top-level parser.

    - Find the cache name
    """
    sentinel = "Write cache to:"
    idx = full_text.find(sentinel)
    if idx == -1:
        assert False and "Can't find desired cache path"
        return ""

    # Start just after the sentinel line
    start = idx + len(sentinel)

    region = full_text[start:].strip()

    return region

def parse_eval_result(full_text:str)->list[EvalResult]:
    """
    Top-level parser.

    - Find the first occurrence of the literal line 'print result'
    - Take everything after that line
    - Split by the exact separator '=======' (7 equals)
    - Call parse_per_bit_result on each chunk and keep only non-empty parsed Results
    - Ignore empty/parsing-failed chunks (this drops trailing metadata or stray text)
    """
    sentinel = "print result"
    idx = full_text.find(sentinel)
    if idx == -1:
        return []

    # Start just after the sentinel line
    start = idx + len(sentinel)

    region = full_text[start:].strip()

    parts = [part.strip() for part in region.split("=======")]
    parts.pop(-1)

    result_list:list[list[PerBitRes]] = []
    for part in parts:
        if not part:
            continue
        per_bit_result_list = parse_per_bit_result(part)
        if per_bit_result_list:               # only keep non-empty parsed results
            if result_list:
                assert len(result_list) == len(per_bit_result_list)
                for i, per_bit_result in enumerate(per_bit_result_list):
                    result_list[i].append(per_bit_result)
            else:
                result_list = [[per_bit_result] for per_bit_result in per_bit_result_list]

    return [EvalResult(_) for _ in result_list]
