import os
import re

# List all base directories here
base_dirs = [
    "./outputs/knownBitsFlag",
    "./outputs/knownBits",
    "./outputs/integerRange",
    "./outputs/integerRangeFlag"
]

pattern = re.compile(r"Iter (\d+) Finished\. Exact: ([\d.]+)%\s+Dis:(\d+)")

results = []

# results = [
#     # examples:
#     ("KnownBitsAddNsw",    14, 58.11, 2268, "./outputs/KnownBitsFlag"),
#     ("KnownBitsAddNuw",    14, 90.79, 508,  "./outputs/KnownBitsFlag"),
#     ("KnownBitsAddNswNuw", 14, 33.74, 2212, "./outputs/KnownBitsFlag"),
#     ("KnownBitsAdd",       14, 97.44, 168,  "./outputs/KnownBits"),
#     ("integerRangeAdd",     3,100.00,   0,  "./outputs/integerRange"),
#     ("integerRangeAddNuw",  0,100.00,   0,  "./outputs/integerRangeFlag"),
#     # … and so on for all folders …
# ]

# --- 1. your collected results: (folder_name, iter, exact, dis, base_dir) ---
for base_dir in base_dirs:
    for folder_name in sorted(os.listdir(base_dir)):
        folder_path = os.path.join(base_dir, folder_name)
        log_file = os.path.join(folder_path, "info.log")

        if not os.path.isfile(log_file):
            continue

        last_match = None
        with open(log_file, "r") as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    last_match = match

        if last_match:
            iter_num, exact, dis = last_match.groups()
            results.append((folder_name, int(iter_num), float(exact), int(dis), base_dir))

# Print results
for name, iter_num, exact, dis, base_dir in results:
    print(f"[{base_dir}] {name}: Iter = {iter_num}, Exact = {exact:.2f}%, Dis = {dis}")

# --- parse folder_name + base_dir into (op_key, flags, domain) ---
def parse_entry(folder_name, base_dir):
    domain = "KnownBits" if "knownBits" in base_dir else "ConstantRange"
    prefix = "KnownBits" if domain=="KnownBits" else "integerRange"
    core = folder_name[len(prefix):]
    m = re.match(r"^([A-Za-z0-9]+?)(Exact|NswNuw|NuwNsw|Nsw|Nuw)?$", core)
    if not m:
        raise ValueError(f"unrecognized folder: {folder_name}")
    op_name, flag = m.groups()
    op_key = op_name.lower()
    if not flag:
        flags = ""
    else:
        f = flag.lower()
        if f in ("nswnuw","nuwnsw"):
            flags = "nsw\\&nuw"
        else:
            flags = f
    return op_key, flags, domain

# build lookup: (op_key, flags, domain) -> exact%
lookup = {}
for folder, it, exact, dis, base in results:
    key = parse_entry(folder, base)
    lookup[key] = exact

# --- rows in the exact order of your template, with display_name, op_key, flags ---
rows = [
    ("and",        "and",        ""),
    ("or",         "or",         ""),
    ("xor",        "xor",        ""),
    # break
    ("add",        "add",        ""),
    ("add",        "add",        "nsw"),
    ("add",        "add",        "nuw"),
    ("add",        "add",        "nsw\\&nuw"),
    ("sub",        "sub",        ""),
    ("sub",        "sub",        "nsw"),
    ("sub",        "sub",        "nuw"),
    ("sub",        "sub",        "nsw\\&nuw"),
    # break
    ("umax",       "umax",       ""),
    ("umin",       "umin",       ""),
    ("smax",       "smax",       ""),
    ("smin",       "smin",       ""),
    ("abdu",       "abdu",       ""),
    ("abds",       "abds",       ""),
    # break
    ("udiv",       "udiv",       ""),
    ("udiv",       "udiv",       "exact"),
    ("sdiv",       "sdiv",       ""),
    ("sdiv",       "sdiv",       "exact"),
    ("urem",       "modu",       ""),
    ("srem",       "mods",       ""),
    ("mul",        "mul",        ""),
    ("mul",        "mul",        "nsw"),
    ("mul",        "mul",        "nuw"),
    ("mul",        "mul",        "nsw\\&nuw"),
    ("mulhs",      "mulhs",      ""),
    ("mulhu",      "mulhu",      ""),
    # break
    ("shl",        "shl",        ""),
    ("shl",        "shl",        "nsw"),
    ("shl",        "shl",        "nuw"),
    ("shl",        "shl",        "nsw\\&nuw"),
    ("lshr",       "lshr",       ""),
    ("lshr",       "lshr",       "exact"),
    ("ashr",       "ashr",       ""),
    ("ashr",       "ashr",       "exact"),
    # break
    ("avgfloors",  "avgfloors",  ""),
    ("avgflooru",  "avgflooru",  ""),
    ("avgceils",   "avgceils",   ""),
    ("avgceilu",   "avgceilu",   ""),
    # break
    ("uadd\\_sat", "uadd_sat",   ""),
    ("usub\\_sat", "usub_sat",   ""),
    ("sadd\\_sat", "sadd_sat",   ""),
    ("ssub\\_sat", "ssub_sat",   ""),
    # break
    ("umul\\_sat", "umul_sat",   ""),
    ("smul\\_sat", "smul_sat",   ""),
    # break
    ("ushl\\_sat", "ushl_sat",   ""),
    ("sshl\\_sat", "sshl_sat",   ""),
]

llvm_lookup = {
    # format: (op_key, flags, domain) : exact%
    ("and",        "",     "KnownBits"):      100.00,
    ("or",         "",     "KnownBits"):      100.00,
    ("xor",        "",     "KnownBits"):      100.00,
    ("add",        "",     "KnownBits"):      100.00,
    ("add",        "nsw",  "KnownBits"):      100.00,
    ("add",        "nuw",  "KnownBits"):      100.00,
    ("add",        "nsw\\&nuw", "KnownBits"): 100.00,
    ("sub",        "",     "KnownBits"):      100.00,
    ("sub",        "nsw",  "KnownBits"):      100.00,
    ("sub",        "nuw",  "KnownBits"):      100.00,
    ("sub",        "nsw\\&nuw", "KnownBits"): 100.00,
    ("umax",       "",     "KnownBits"):      100.00,
    ("umin",       "",     "KnownBits"):      100.00,
    ("smax",       "",     "KnownBits"):      100.00,
    ("smin",       "",     "KnownBits"):      100.00,
    ("abdu",       "",     "KnownBits"):      100.00,
    ("abds",       "",     "KnownBits"):      100.00,
    ("shl",        "",     "KnownBits"):      100.00,
    ("shl",        "nsw",  "KnownBits"):      100.00,
    ("shl",        "nuw",  "KnownBits"):      100.00,
    ("shl",        "nsw\\&nuw", "KnownBits"): 100.00,
    ("lshr",       "",     "KnownBits"):      100.00,
    ("lshr",       "exact","KnownBits"):      100.00,
    ("ashr",       "",     "KnownBits"):      100.00,
    ("ashr",       "exact","KnownBits"):      100.00,
    ("avgfloors",  "",     "KnownBits"):      100.00,
    ("avgflooru",  "",     "KnownBits"):      100.00,
    ("avgceils",   "",     "KnownBits"):      100.00,
    ("avgceilu",   "",     "KnownBits"):      100.00,
    ("uadd_sat", "",     "KnownBits"):      100.00,
    ("usub_sat", "",     "KnownBits"):      100.00,
    ("sadd_sat", "",     "KnownBits"):      100.00,
    ("ssub_sat", "",     "KnownBits"):      100.00,
    ("add",        "",     "ConstantRange"): 100.00,
    ("add",        "nsw",  "ConstantRange"): 100.00,
    ("add",        "nuw",  "ConstantRange"): 100.00,
    ("add",        "nsw\\&nuw", "ConstantRange"): 100.00,
    ("sub",        "",     "ConstantRange"): 100.00,
    ("sub",        "nsw",  "ConstantRange"): 100.00,
    ("sub",        "nuw",  "ConstantRange"): 100.00,
    ("sub",        "nsw\\&nuw", "ConstantRange"): 100.00,
    ("umax",       "",     "ConstantRange"): 100.00,
    ("umin",       "",     "ConstantRange"): 100.00,
    ("smax",       "",     "ConstantRange"): 100.00,
    ("smin",       "",     "ConstantRange"): 100.00,
    # etc.
}

special_lookup = {
    # say you want to mark that “add nsw” only has KnownBits but no ConstantRange:
    ("avgfloors",   "",      "ConstantRange"): r"\textit{n/a}",
    ("avgflooru",   "",      "ConstantRange"): r"\textit{n/a}",
    ("avgceils",   "",      "ConstantRange"): r"\textit{n/a}",
    ("avgceilu",   "",      "ConstantRange"): r"\textit{n/a}",
    ("udiv", "exact", "ConstantRange"): r"\textit{n/a}",
    ("sdiv", "exact", "ConstantRange"): r"\textit{n/a}",
    ("lshr", "exact", "ConstantRange"): r"\textit{n/a}",
    ("ashr", "exact", "ConstantRange"): r"\textit{n/a}",
    ("abdu",   "",      "ConstantRange"): r"\textit{n/a}",
    ("abds",   "",      "ConstantRange"): r"\textit{n/a}",
    ("mulhs",   "",      "ConstantRange"): r"\textit{n/a}",
    ("mulhu",   "",      "ConstantRange"): r"\textit{n/a}",
    ("umul_sat",   "",      "KnownBits"): r"\textit{n/a}",
    ("smul_sat",   "",      "KnownBits"): r"\textit{n/a}",
    ("ushl_sat",   "",      "KnownBits"): r"\textit{n/a}",
    ("sshl_sat",   "",      "KnownBits"): r"\textit{n/a}",
    # … add as many manual labels as you like …
}

# the indices after which to insert \midrule
mid_after = {2, 10, 16, 28, 36, 40, 44, 46}


# now decide each cell:
def fmt(key, val):
    # first check your manual override
    if key in special_lookup:
        return special_lookup[key]
    # then if you have a numeric val
    if val is not None:
        return f"{val:.2f}\\%"
    # otherwise leave blank
    return ""

with open("table.tex", "w") as tex:
    # --- emit LaTeX ---
    print(r"\begin{tabular}{llcccc}", file=tex)
    print(r"  \toprule", file=tex)
    print(r"  \textbf{concrete\_op} & \textbf{flags} & \multicolumn{2}{c}{\textbf{KnownBits}} & \multicolumn{2}{c}{\textbf{ConstantRange}} \\",file=tex)
    print(r"                        &                & LLVM Exact\% & Our Exact\% & LLVM Exact\% & Our Exact\% \\",file=tex)
    print(r"  \midrule",file=tex)

    for idx, (disp, op_key, flags) in enumerate(rows):
        # look up numbers (None if missing)
        ll_kb = llvm_lookup.get((op_key, flags, "KnownBits"))
        our_kb = lookup.get((op_key, flags, "KnownBits"))
        ll_cr = llvm_lookup.get((op_key, flags, "ConstantRange"))
        our_cr = lookup.get((op_key, flags, "ConstantRange"))

        ll_kb_str  = fmt((op_key, flags, "KnownBits"),      ll_kb)
        our_kb_str = fmt((op_key, flags, "KnownBits"),      our_kb)
        ll_cr_str  = fmt((op_key, flags, "ConstantRange"),  ll_cr)
        our_cr_str = fmt((op_key, flags, "ConstantRange"),  our_cr)

        # print the row
        print(f"  {disp} & {flags} & {ll_kb_str} & {our_kb_str} & {ll_cr_str} & {our_cr_str} \\\\",file=tex)
        if idx in mid_after:
            print(r"  \midrule",file=tex)

    print(r"  \bottomrule",file=tex)
    print(r"\end{tabular}",file=tex)


