pragma solidity ^0.4.23;

import './../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';


/// @title ContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev Base class
contract ContributionForwarder {


    using SafeMath for uint256;

    uint256 public weiCollected;
    uint256 public weiForwarded;

    event ContributionForwarded(address receiver, uint256 weiAmount);

    function isInitialized() public constant returns (bool) {
        return false;
    }

    /// @notice transfer wei to receiver
    function forward() public payable {
        require(msg.value > 0);

        weiCollected += msg.value;

        internalForward();
    }

    function internalForward() internal;
}

