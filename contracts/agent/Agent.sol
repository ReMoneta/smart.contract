pragma solidity ^0.4.23;

import './../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';


/// @title Agent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract Agent {
    using SafeMath for uint256;

    function isInitialized() public constant returns (bool) {
        return false;
    }
}

