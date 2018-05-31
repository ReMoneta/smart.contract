pragma solidity ^0.4.23;

import '../Pausable.sol';

/// @title PausableToken
/// @author Applicature
/// @notice helper mixed to other contracts to pause/un pause contract
/// @dev Base class
contract PausableToken is Pausable {

    constructor(bool _paused) public Pausable(_paused) {

    }

    function pause() public onlyPauseAgents() {
        paused = true;
    }

    function unpause() public onlyPauseAgents() {
        paused = false;
    }
}
