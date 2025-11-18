from typing import List

from xdsl.dialects.func import FuncOp

from xdsl_smt.egraph_rewriter.expr_builder import ExprBuilder, simplify_term


def rewrite_function(func: FuncOp) -> FuncOp:
    """
    Rewrite a single transfer function by iterating over all its statements.
    This function specifically handles functions ending with "_body" or "_cond".
    For now, this is just a placeholder that loops through all operations without modification.

    Args:
        func: The function to rewrite (should end with "_body" or "_cond")

    Returns:
        The modified function (currently unmodified)
    """
    function_name = func.sym_name.data
    print(f"Rewriting function: {function_name}")

    # Verify this is a function we should be rewriting
    if not (function_name.endswith("_body") or function_name.endswith("_cond")):
        print(
            f"  WARNING: Function {function_name} doesn't end with '_body' or '_cond'"
        )

    # Get the function body (first block)
    if not func.body.blocks:
        print(f"  Function {function_name} has no body")
        return func

    expr_builder = ExprBuilder(func)
    expr_builder.build_expr()
    for i, expr in enumerate(expr_builder.ret_exprs):
        simplfied, previous_cost, new_cost = simplify_term(expr)
        print(f"Known{i}: {previous_cost} -> {new_cost}")
        print(f"  Before: {expr}")
        print(f"  After:  {simplfied}")
    print("\n")
    return func


def should_rewrite_function(func: FuncOp) -> bool:
    """
    Check if a function should be rewritten based on its name.
    Only functions ending with "_body" or "_cond" should be rewritten.
    """
    function_name = func.sym_name.data
    return function_name.endswith("_body") or function_name.endswith("_cond")


def rewrite_transfer_functions(xfer_funcs: List[FuncOp]) -> List[FuncOp]:
    """
    Rewrite transfer functions provided by postprocessor.py.
    Only functions ending with "_body" or "_cond" will be rewritten.

    Args:
        xfer_funcs: List of transfer functions to rewrite (from postprocessor.py)

    Returns:
        List of rewritten transfer functions
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

    # Rewrite only the filtered functions
    rewritten_funcs: List[FuncOp] = []

    # Add the functions we're skipping unchanged
    rewritten_funcs.extend(functions_to_skip)

    # Rewrite the functions we want to process
    for func in functions_to_rewrite:
        rewritten_func = rewrite_function(func)
        rewritten_funcs.append(rewritten_func)

    return rewritten_funcs
