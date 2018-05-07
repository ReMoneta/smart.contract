pragma solidity ^0.4.18;


/// @title BlockLocked
/// @author Applicature
/// @notice helper mixed to other contracts to lock contract on a block
/// @dev Base class
contract BlockLocked {
    uint256 public blockNumber;

    modifier isBlockLocked(bool _blockLocked) {
        bool locked = (block.number < blockNumber);

        require(locked == _blockLocked);

        _;
    }

    function BlockLocked(uint256 _blockNumber) public {
        blockNumber = _blockNumber;
    }
}
