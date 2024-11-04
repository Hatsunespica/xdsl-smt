from xdsl.ir import ParametrizedAttribute, TypeAttribute, SSAValue, Dialect, Attribute
from xdsl.irdl import (
    IRDLOperation,
    irdl_attr_definition,
    operand_def,
    result_def,
    irdl_op_definition,
)
from xdsl.utils.exceptions import VerifyException
from xdsl.utils.isattr import isattr

from xdsl_smt.dialects.smt_bitvector_dialect import BitVectorType
from xdsl_smt.dialects.smt_dialect import BoolType
from xdsl_smt.dialects.smt_utils_dialect import PairType


@irdl_attr_definition
class MemoryType(ParametrizedAttribute, TypeAttribute):
    """Type of the memory state."""

    name = "memory.memory"


@irdl_attr_definition
class BlockIDType(ParametrizedAttribute, TypeAttribute):
    """Type of a block ID."""

    name = "memory.block_id"


@irdl_attr_definition
class MemoryBlockType(ParametrizedAttribute, TypeAttribute):
    """Type of a memory block."""

    name = "memory.block"


@irdl_attr_definition
class BytesType(ParametrizedAttribute, TypeAttribute):
    """Type of a sequence of memory bytes."""

    name = "memory.bytes"


@irdl_attr_definition
class ByteType(ParametrizedAttribute, TypeAttribute):
    """Type of a memory byte."""

    name = "memory.byte"


@irdl_op_definition
class GetBlockOp(IRDLOperation):
    """Get a memory block from a memory state."""

    name = "memory.get_block"

    memory = operand_def(MemoryType())
    block_id = operand_def(BlockIDType())

    res = result_def(MemoryBlockType())

    assembly_format = "$memory `[` $block_id `]` attr-dict"

    def __init__(self, memory: SSAValue, block_id: SSAValue):
        super().__init__(operands=[memory, block_id], result_types=[MemoryBlockType()])
        self.res.name_hint = "block"


@irdl_op_definition
class SetBlockOp(IRDLOperation):
    """Set a memory block in a memory state."""

    name = "memory.set_block"

    block = operand_def(MemoryBlockType())
    memory = operand_def(MemoryType())
    block_id = operand_def(BlockIDType())

    res = result_def(MemoryType())

    assembly_format = "$block `,` $memory `[` $block_id `]` attr-dict"

    def __init__(self, block: SSAValue, memory: SSAValue, block_id: SSAValue):
        super().__init__(
            operands=[block, memory, block_id], result_types=[MemoryType()]
        )
        self.res.name_hint = "memory"


@irdl_op_definition
class GetBlockBytesOp(IRDLOperation):
    """Get the bytes of a memory block."""

    name = "memory.get_block_bytes"

    memory_block = operand_def(MemoryBlockType())

    res = result_def(BytesType())

    assembly_format = "$memory_block attr-dict"

    def __init__(self, memory_block: SSAValue):
        super().__init__(operands=[memory_block], result_types=[BytesType()])
        self.res.name_hint = "block_bytes"


@irdl_op_definition
class SetBlockBytesOp(IRDLOperation):
    """Set the bytes of a memory block."""

    name = "memory.set_block_bytes"

    memory_block = operand_def(MemoryBlockType())
    bytes = operand_def(BytesType())

    res = result_def(MemoryBlockType())

    assembly_format = "$bytes `,` $memory_block attr-dict"

    def __init__(self, bytes: SSAValue, memory_block: SSAValue):
        super().__init__(
            operands=[bytes, memory_block], result_types=[MemoryBlockType()]
        )
        self.res.name_hint = "block"


@irdl_op_definition
class GetBlockSizeOp(IRDLOperation):
    """Get the size of a memory block in bytes."""

    name = "memory.get_block_size"

    memory_block = operand_def(MemoryBlockType())

    res = result_def(BitVectorType(64))

    assembly_format = "$memory_block attr-dict"

    def __init__(self, memory_block: SSAValue):
        super().__init__(operands=[memory_block], result_types=[BitVectorType(64)])
        self.res.name_hint = "block_size"


@irdl_op_definition
class SetBlockSizeOp(IRDLOperation):
    """Set the size of a memory block in bytes."""

    name = "memory.set_block_size"

    memory_block = operand_def(MemoryBlockType())
    size = operand_def(BitVectorType(64))

    res = result_def(MemoryBlockType())

    assembly_format = "$memory_block `,` $size attr-dict"

    def __init__(self, memory_block: SSAValue, size: SSAValue):
        super().__init__(
            operands=[memory_block, size], result_types=[MemoryBlockType()]
        )
        self.res.name_hint = "block"


@irdl_op_definition
class GetBlockLiveMarkerOp(IRDLOperation):
    """
    Get the live marker of a memory block.
    A block is live if it is reachable from the memory state.
    """

    name = "memory.get_live_marker"

    memory_block = operand_def(MemoryBlockType())

    res = result_def(BoolType())

    assembly_format = "$memory_block attr-dict"

    def __init__(self, memory_block: SSAValue):
        super().__init__(operands=[memory_block], result_types=[BoolType()])
        self.res.name_hint = "is_live"


@irdl_op_definition
class SetBlockLiveMarkerOp(IRDLOperation):
    """
    Set the live marker of a memory block.
    A block is live if it is reachable from the memory state.
    """

    name = "memory.set_block_live_marker"

    memory_block = operand_def(MemoryBlockType())
    live = operand_def(BoolType())

    res = result_def(MemoryBlockType())

    assembly_format = "$memory_block `,` $live attr-dict"

    def __init__(self, memory_block: SSAValue, live: SSAValue):
        super().__init__(
            operands=[memory_block, live], result_types=[MemoryBlockType()]
        )
        self.res.name_hint = "block"


@irdl_op_definition
class ReadBytesOp(IRDLOperation):
    """
    Read a (possibly poisoned) bitvector in an infinite sequence of bytes.
    The index is the first byte to read, and the read bitvector is expected
    to be a multiple of 8 bits.
    """

    name = "memory.read_bytes"

    bytes = operand_def(BytesType())
    index = operand_def(BitVectorType(64))

    res = result_def(PairType[BitVectorType, BoolType])

    assembly_format = "$bytes `[` $index `]` attr-dict `:` type($res)"

    def __init__(self, bytes: SSAValue, index: SSAValue, res_type: Attribute):
        super().__init__(operands=[bytes, index], result_types=[res_type])
        self.res.name_hint = "read"

    def verify_(self):
        assert isattr(self.res.type, PairType[BitVectorType, BoolType])
        if self.res.type.first.width.data % 8 != 0:
            raise VerifyException("return bitvector must have a multiple of 8 bitwidth")


@irdl_op_definition
class WriteBytesOp(IRDLOperation):
    """
    Write a (possibly poisoned) bitvector in an infinite sequence of bytes.
    The index is the first byte to read, and the read bitvector is expected
    to be a multiple of 8 bits.
    """

    name = "memory.write_bytes"

    value = operand_def(PairType[BitVectorType, BoolType])
    bytes = operand_def(BytesType())
    index = operand_def(BitVectorType(64))

    res = result_def(BytesType())

    assembly_format = "$value `,` $bytes `[` $index `]` attr-dict `:` type($value)"

    def __init__(self, value: SSAValue, bytes: SSAValue, index: SSAValue):
        super().__init__(operands=[value, bytes, index], result_types=[BytesType()])
        self.res.name_hint = "bytes"


@irdl_op_definition
class GetFreshBlockIDOp(IRDLOperation):
    """
    Allocate a fresh block ID.
    The block ID is different than any block that is currently live.
    In particular, it may reuse block IDs of blocks that are no longer live.
    """

    name = "memory.get_fresh_block_id"

    memory = operand_def(MemoryType())

    res = result_def(BlockIDType())

    assembly_format = "$memory attr-dict"

    def __init__(self, memory: SSAValue):
        super().__init__(operands=[memory], result_types=[BlockIDType()])
        self.res.name_hint = "bid"


MemoryDialect = Dialect(
    "memory",
    [
        GetBlockOp,
        SetBlockOp,
        GetBlockBytesOp,
        SetBlockBytesOp,
        GetBlockSizeOp,
        SetBlockSizeOp,
        GetBlockLiveMarkerOp,
        SetBlockLiveMarkerOp,
        ReadBytesOp,
        WriteBytesOp,
        GetFreshBlockIDOp,
    ],
    [
        MemoryType,
        BlockIDType,
        MemoryBlockType,
        BytesType,
        ByteType,
    ],
)
