pragma solidity ^0.4.18;


import './Ownable.sol';


/// @title Pausable
/// @author Applicature
/// @notice helper mixed to other contracts to pause/un pause contract
/// @dev Base class
contract Pausable is Ownable {


    bool public paused;
    mapping(address => bool) public pauseAgents;

    modifier onlyPauseAgents() {
        require(pauseAgents[msg.sender]);
        _;
    }

    modifier isPaused(bool _paused) {
        require(paused == _paused);
        _;
    }

    function Pausable(bool _paused) public {
        paused = _paused;
        pauseAgents[msg.sender] = true;
    }

    function pause() public onlyPauseAgents() {
        paused = true;
    }

    function unpause() public onlyPauseAgents() {
        paused = false;
    }

    function addPauseAgent(address _agent) public onlyOwner {
        pauseAgents[_agent] = true;
    }

    function removePauseAgent(address _agent) public onlyOwner {
        pauseAgents[_agent] = false;
    }
}

