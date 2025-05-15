from xdsl.dialects.func import FuncOp, ReturnOp
from xdsl.ir import Operation, SSAValue

from xdsl_smt.dialects.transfer import MakeOp

from xdsl_smt.utils.synthesizer_utils.synthesizer_context import (
    not_in_main_body,
    is_of_type,
)


class MutationProgram:
    """
    Represents a program that is mutated during MCMC.

    Attributes:
        func (FuncOp): The mutation program.
        ops (list[Operation]): A list of operations within the function's body.

    The user should **manually** maintain the consistency between func and ops.
    """

    func: FuncOp
    old_op: None | Operation
    new_op: None | Operation

    def __init__(self, func: FuncOp):
        self.func = func
        self.old_op = None
        self.new_op = None

    @property
    def ops(self):
        return list(self.func.body.block.ops)

    def get_modifiable_operations(
        self, only_live: bool = True
    ) -> list[tuple[Operation, int]]:
        """
        Get live operations when only_live = True, otherwise return all operations in the main body
        """
        modifiable_ops = list[tuple[Operation, int]]()
        live_set = set[Operation]()

        assert isinstance(self.ops[-1], ReturnOp)

        if isinstance(self.ops[-2], MakeOp):  # regular function
            last_make_op = self.ops[-2]
            for operand in last_make_op.operands:
                assert isinstance(operand.owner, Operation)
                live_set.add(operand.owner)
        else:  # condition
            assert not not_in_main_body(self.ops[-2])
            live_set.add(self.ops[-2])

        for idx in range(len(self.ops) - 2, -1, -1):
            operation = self.ops[idx]
            if not_in_main_body(operation):
                continue
            if only_live:
                if operation in live_set:
                    modifiable_ops.append((operation, idx))
                    for operand in operation.operands:
                        assert isinstance(operand.owner, Operation)
                        live_set.add(operand.owner)
            else:
                modifiable_ops.append((operation, idx))

        return modifiable_ops

    def remove_history(self):
        assert self.old_op is not None
        assert self.new_op is not None
        self.old_op.erase()
        self.new_op = None
        self.old_op = None

    def revert_operation(self):
        assert self.old_op is not None
        assert self.new_op is not None
        self.replace_operation(self.new_op, self.old_op, False)
        self.new_op.erase()
        self.new_op = None
        self.old_op = None

    def replace_operation(self, old_op: Operation, new_op: Operation, history: bool):
        """
        Replace the old_op with the given new operation.
        """
        if history:
            self.old_op = old_op
            self.new_op = new_op

        block = self.func.body.block
        block.insert_op_before(new_op, old_op)
        if len(old_op.results) > 0 and len(new_op.results) > 0:
            old_op.results[0].replace_by(new_op.results[0])
        block.detach_op(old_op)

    def get_valid_operands(self, x: int, ty: str) -> list[SSAValue]:
        """
        Get operations that return a value of type ty and are before ops[x], which can serve as operands
        """
        return [op.results[0] for op in self.ops[:x] if is_of_type(op, ty)]
