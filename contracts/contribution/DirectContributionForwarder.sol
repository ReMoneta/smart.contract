pragma solidity ^0.4.23;


import './ContributionForwarder.sol';


/// @title DirectContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev implementation
contract DirectContributionForwarder is ContributionForwarder {


    address public receiver;

    constructor(address _receiver) public {
        receiver = _receiver;
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    function internalForward() internal {
        receiver.transfer(msg.value);

        weiForwarded = weiForwarded.add(msg.value);

        emit ContributionForwarded(receiver, msg.value);
    }

}

