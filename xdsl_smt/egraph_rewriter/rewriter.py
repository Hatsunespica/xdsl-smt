from typing import List

from xdsl.dialects.func import FuncOp

import egglog

from xdsl_smt.egraph_rewriter.expr_builder import (
    ExprBuilder,
    build_meet_expr,
    simplify_term,
)


def rewrite_function(func: FuncOp) -> tuple[egglog.Expr, ...]:
    """
    Rewrite a single transfer function by iterating over all its statements.
    This function specifically handles functions ending with "_body" or "_cond".
    Prints the expressions without returning anything.

    Args:
        func: The function to rewrite (should end with "_body" or "_cond")
    """
    function_name = func.sym_name.data
    print(f"Rewriting function: {function_name}")

    expr_builder = ExprBuilder(func)
    expr_builder.build_expr()
    rewritten_exprs = []
    for i, expr in enumerate(expr_builder.ret_exprs):
        simplfied, previous_cost, new_cost = simplify_term(expr)
        print(f"Known{i}: {previous_cost} -> {new_cost}")
        # print(f"  Before: {expr}")
        # print(f"  After:  {simplfied}")
        rewritten_exprs.append(simplfied)
    print("\n")

    return tuple(rewritten_exprs)


def should_rewrite_function(func: FuncOp) -> bool:
    """
    Check if a function should be rewritten based on its name.
    Only functions ending with "_body" or "_cond" should be rewritten.
    """
    function_name = func.sym_name.data
    return function_name.endswith("_body") or function_name.endswith("_cond")


def rewrite_transfer_functions(
    xfer_funcs: List[FuncOp],
) -> list[tuple[egglog.Expr, ...]]:
    """
    Rewrite transfer functions provided by postprocessor.py.
    Only functions ending with "_body" or "_cond" will be rewritten.

    Args:
        xfer_funcs: List of transfer functions to rewrite (from postprocessor.py)
    """
    print(f"Starting rewrite of {len(xfer_funcs)} transfer functions")

    # Filter functions to only include those ending with "_body" or "_cond"
    functions_to_rewrite = [
        func for func in xfer_funcs if should_rewrite_function(func)
    ]
    functions_to_skip = [
        func for func in xfer_funcs if not should_rewrite_function(func)
    ]

    print(
        f"Found {len(functions_to_rewrite)} functions to rewrite (ending with '_body' or '_cond'):"
    )
    for func in functions_to_rewrite:
        print(f"  - {func.sym_name.data}")

    if functions_to_skip:
        print(
            f"Skipping {len(functions_to_skip)} functions (not ending with '_body' or '_cond'):"
        )
        for func in functions_to_skip:
            print(f"  - {func.sym_name.data}")

    # Rewrite the functions we want to process
    rewritten_funcs = []
    for func in functions_to_rewrite:
        rewritten_funcs.append(rewrite_function(func))
    return rewritten_funcs


def rewrite_meet_of_all_functions(all_ret_exprs: List[tuple[egglog.Expr, ...]]) -> None:
    """
    Process meet expressions for functions ending with "_body".

    Args:
        all_ret_exprs: List of return expressions from transfer functions
    """
    print(f"Building meet of {len(all_ret_exprs)} functions")
    meet_exprs = build_meet_expr(all_ret_exprs)
    print(f"Done. ")
    for i, expr in enumerate(meet_exprs):
        simplfied, previous_cost, new_cost = simplify_term(expr)
        print(f"Known{i}: {previous_cost} -> {new_cost}")
        print(f"  Before: {expr}")
        print(f"  After:  {simplfied}")
    print("\n")


# def rewrite_meet_of_all_functions(xfer_funcs: List[FuncOp]) -> None:
#     """
#     Process meet expressions for functions ending with "_body".

#     Args:
#         xfer_funcs: List of transfer functions to process
#     """
#     functions_in_meet = [
#         func for func in xfer_funcs if func.sym_name.data.endswith("_body")
#     ]

#     all_ret_exprs = []
#     for func in functions_in_meet:
#         expr_builder = ExprBuilder(func)
#         expr_builder.build_expr()
#         all_ret_exprs.append(expr_builder.ret_exprs)
#     print(f"Building meet of {len(functions_in_meet)} functions")
#     meet_exprs = build_meet_expr(all_ret_exprs)
#     print(f"Done. ")
#     for i, expr in enumerate(meet_exprs):
#         simplfied, previous_cost, new_cost = simplify_term(expr)
#         print(f"Known{i}: {previous_cost} -> {new_cost}")
#         print(f"  Before: {expr}")
#         print(f"  After:  {simplfied}")
#     print("\n")
