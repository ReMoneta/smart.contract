pragma solidity ^0.4.18;

import './ContributionForwarder.sol';

/// @title ClaimableContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev implementation
contract ClaimableContributionForwarder is ContributionForwarder {
    address public receiver;

    function ClaimableContributionForwarder(address _receiver) public {
        receiver = _receiver;
    }

    /// @notice transfer wei to receiver
    function transfer() public {
        weiForwarded = weiForwarded.add(this.balance);

        receiver.transfer(this.balance);

        ContributionForwarded(receiver, this.balance);
    }

    function internalForward() internal {
        // nothing to do
    }
}
