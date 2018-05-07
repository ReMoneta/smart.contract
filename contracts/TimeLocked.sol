pragma solidity ^0.4.18;

/// @title TimeLocked
/// @author Applicature
/// @notice helper mixed to other contracts to lock contract on a timestamp
/// @dev Base class
contract TimeLocked {
    uint256 public time;

    modifier isTimeLocked(bool _timeLocked) {
        bool locked = (block.timestamp < time);

        require(locked == _timeLocked);

        _;
    }

    function TimeLocked(uint256 _time) public {
        time = _time;
    }
}
