from abc import ABC, abstractmethod
from enum import Enum
from typing import List, Tuple

from xdsl.dialects.builtin import IntegerAttr, i1
from xdsl.irdl import IRDLOperation

from ..dialects.transfer import (
    NegOp,
    CmpOp,
    AndOp,
    OrOp,
    XorOp,
    AddOp,
    SubOp,
    MulOp,
    CountLOneOp,
    CountLZeroOp,
    CountROneOp,
    CountRZeroOp,
    SetHighBitsOp,
    SetLowBitsOp,
    # GetLowBitsOp,
    GetBitWidthOp,
    UMulOverflowOp,
    # SMinOp,
    # SMaxOp,
    # UMinOp,
    # UMaxOp,
    ShlOp,
    LShrOp,
    SelectOp,
    Constant,
    GetAllOnesOp,
)
from xdsl.ir import Operation, SSAValue
import xdsl.dialects.arith as arith
from xdsl_smt.utils.random import Random


class SynthType(Enum):
    INT = 1
    BOOL = 2
    BOUNDED_INT = 3


def filter_ops(
    ops: List[SSAValue],
    types_to_filter: Tuple[type[Operation], ...],
    others: List[SSAValue] = [],
) -> List[SSAValue]:
    return [
        op for op in ops if not (isinstance(op.owner, types_to_filter) or op in others)
    ]


class SynthOperator(IRDLOperation, ABC):
    """
    An abstract base class for all mutable synthesis operators.
    """

    operands_types: list[SynthType]
    res_type: SynthType
    commutative: bool = False
    idempotent: bool = False
    skip_trivial: bool = True

    @staticmethod
    @abstractmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ) -> Operation | None:
        """
        Return a new operation with random operands.
        Return None if failed.
        """
        pass

    @abstractmethod
    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ) -> bool:
        """
        Replace an operand in the operation.
        Return False if failed.
        """
        pass


class SyZero(Constant):
    def __init__(self, arg_for_bitw: SSAValue):
        super().__init__(arg_for_bitw, 0)


class SyOne(Constant):
    def __init__(self, arg_for_bitw: SSAValue):
        super().__init__(arg_for_bitw, 1)


class SyAllOnes(GetAllOnesOp):
    def __init__(self, arg_for_bitw: SSAValue):
        super().__init__(arg_for_bitw)


class SyTrue(arith.ConstantOp):
    def __init__(self):
        super().__init__(IntegerAttr.from_int_and_width(1, 1), i1)


class SyFalse(arith.ConstantOp):
    def __init__(self):
        super().__init__(IntegerAttr.from_int_and_width(0, 1), i1)


class SyBitWidth(GetBitWidthOp):
    def __init__(self, arg: SSAValue):
        super().__init__(arg)


class SyNeg(NegOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        return SyNeg(int_val1)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 1:
                return False
        ith = rd.randint(0, len(self.operands) - 1)
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyAdd(AddOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero,))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyAdd(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero,))
            if len(int_ops) < 1:
                return False
        ith = rd.randint(0, len(self.operands) - 1)
        self.operands[ith] = rd.choice(int_ops)
        return True


class SySub(SubOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero,))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SySub(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (SyZero,), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyMul(MulOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyMul(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyOne))
            if len(int_ops) < 1:
                return False
        ith = rd.randint(0, len(self.operands) - 1)
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyAnd(AndOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 2:
                return None
        int_val1, int_val2 = rd.choice2(int_ops)
        return SyAnd(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyOr(OrOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 2:
                return None
        int_val1, int_val2 = rd.choice2(int_ops)
        return SyOr(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyXor(XorOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 2:
                return None
        int_val1, int_val2 = rd.choice2(int_ops)
        return SyXor(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyAndI(arith.AndIOp, SynthOperator):
    res_type = SynthType.BOOL

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            bool_ops = filter_ops(bool_ops, (SyTrue, SyFalse))
            if len(bool_ops) < 2:
                return None

        bool_val1, bool_val2 = rd.choice2(bool_ops)
        return SyAndI(bool_val1, bool_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            bool_ops = filter_ops(bool_ops, (SyTrue, SyFalse), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(bool_ops)
        return True


class SyEq(CmpOp, SynthOperator):
    res_type = SynthType.BOOL

    def __init__(self, lhs: SSAValue, rhs: SSAValue):
        super().__init__(lhs, rhs, "eq")

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial and len(int_ops) < 2:
            return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyEq(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyUlt(CmpOp, SynthOperator):
    res_type = SynthType.BOOL

    def __init__(self, lhs: SSAValue, rhs: SSAValue):
        super().__init__(lhs, rhs, "ult")

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial and len(int_ops) < 2:
            return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyUlt(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyUle(CmpOp, SynthOperator):
    res_type = SynthType.BOOL

    def __init__(self, lhs: SSAValue, rhs: SSAValue):
        super().__init__(lhs, rhs, "ule")

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            if len(int_ops) < 2:
                return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyUle(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            other = self.operands[1 - ith]
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes), [other])
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyCountLZero(CountLZeroOp, SynthOperator):
    res_type = SynthType.BOUNDED_INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        return SyCountLZero(int_val1)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyCountRZero(CountRZeroOp, SynthOperator):
    res_type = SynthType.BOUNDED_INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        return SyCountRZero(int_val1)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyCountLOne(CountLOneOp, SynthOperator):
    res_type = SynthType.BOUNDED_INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        return SyCountLOne(int_val1)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SyCountROne(CountROneOp, SynthOperator):
    res_type = SynthType.BOUNDED_INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        return SyCountROne(int_val1)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            if len(int_ops) < 1:
                return False
        self.operands[ith] = rd.choice(int_ops)
        return True


class SySelect(SelectOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            bool_ops = filter_ops(bool_ops, (SyTrue, SyFalse))
            if len(bool_ops) < 1 or len(int_ops) < 2:
                return None
        int_val1, int_val2 = rd.choice2(int_ops)
        bool_val = rd.choice(bool_ops)
        return SySelect(bool_val, int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if ith == 0:
            if SynthOperator.skip_trivial:
                bool_ops = filter_ops(bool_ops, (SyTrue, SyFalse))
                if len(bool_ops) < 1:
                    return False
            self.operands[ith] = rd.choice(bool_ops)
        else:
            if SynthOperator.skip_trivial:
                other = self.operands[3 - ith]
                int_ops = filter_ops(int_ops, (), [other])
                if len(int_ops) < 1:
                    return False
            self.operands[ith] = rd.choice(int_ops)
        return True


class SyShl(ShlOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        bint_val = rd.choice(bint_ops)
        return SyShl(int_val1, bint_val)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return False
        if ith == 0:
            self.operands[ith] = rd.choice(int_ops)
        else:
            self.operands[ith] = rd.choice(bint_ops)
        return True


class SyLShr(LShrOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        bint_val = rd.choice(bint_ops)
        return SyLShr(int_val1, bint_val)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return False
        if ith == 0:
            self.operands[ith] = rd.choice(int_ops)
        else:
            self.operands[ith] = rd.choice(bint_ops)
        return True


class SySetLowBits(SetLowBitsOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        bint_val = rd.choice(bint_ops)
        return SySetLowBits(int_val1, bint_val)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return False
        if ith == 0:
            self.operands[ith] = rd.choice(int_ops)
        else:
            self.operands[ith] = rd.choice(bint_ops)
        return True


class SySetHighBits(SetHighBitsOp, SynthOperator):
    res_type = SynthType.INT

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        bint_val = rd.choice(bint_ops)
        return SySetHighBits(int_val1, bint_val)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        ith = rd.randint(0, len(self.operands) - 1)
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyAllOnes, SyOne))
            bint_ops = filter_ops(bint_ops, (SyBitWidth,))
            if len(bint_ops) < 1 or len(int_ops) < 1:
                return False
        if ith == 0:
            self.operands[ith] = rd.choice(int_ops)
        else:
            self.operands[ith] = rd.choice(bint_ops)
        return True


class SyUMulOverflow(UMulOverflowOp, SynthOperator):
    res_type = SynthType.BOOL

    @staticmethod
    def get_new_random_op(
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyOne))
            if len(int_ops) < 1:
                return None
        int_val1 = rd.choice(int_ops)
        int_val2 = rd.choice(int_ops)
        return SyUMulOverflow(int_val1, int_val2)

    def replace_an_operand(
        self,
        rd: Random,
        int_ops: list[SSAValue],
        bool_ops: list[SSAValue],
        bint_ops: list[SSAValue],
    ):
        if SynthOperator.skip_trivial:
            int_ops = filter_ops(int_ops, (SyZero, SyOne))
            if len(int_ops) < 1:
                return False
        ith = rd.randint(0, len(self.operands) - 1)
        self.operands[ith] = rd.choice(int_ops)
        return True
