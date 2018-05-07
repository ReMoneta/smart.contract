pragma solidity ^0.4.18;

import './ContributionForwarder.sol';


/// @title ClaimableContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev implementation
contract CappedFifoDirectContributionForwarder is ContributionForwarder {
    Receiver[] public receivers;

    struct Receiver {
        address receiver;
        uint256 maxWeiForward; // how many wei to transfer
        uint256 forwardedWei;
    }

    // @TODO: should we use uint256 [] for receivers & proportions?
    function CappedFifoDirectContributionForwarder(
        address[] _receivers, uint256[] _proportions
    )
    public
    {
        require(_receivers.length == _proportions.length);

        require(_receivers.length > 0);

        for (uint256 i = 0; i < _receivers.length; i++) {
            uint256 maxWeiTransfer = _proportions[i];

            receivers.push(Receiver(_receivers[i], maxWeiTransfer, 0));
        }
    }

    function internalForward() internal {
        uint256 remainingValue = msg.value;

        for (uint256 i = 0; i < receivers.length; i++) {
            Receiver storage receiver = receivers[i];
            uint256 transferValue;

            if (receiver.forwardedWei < receiver.maxWeiForward) {
                if (receiver.forwardedWei.add(remainingValue) > receiver.maxWeiForward) {
                    transferValue = receiver.maxWeiForward.sub(receiver.forwardedWei);

                    remainingValue = remainingValue.sub(transferValue);

                    receiver.forwardedWei = receiver.forwardedWei.add(transferValue);

                    receiver.receiver.transfer(transferValue);

                    ContributionForwarded(receiver.receiver, transferValue);
                } else {
                    receiver.forwardedWei = receiver.forwardedWei.add(remainingValue);

                    transferValue = remainingValue;

                    remainingValue = 0;

                    receiver.receiver.transfer(transferValue);

                    ContributionForwarded(receiver.receiver, remainingValue);
                }
            }
        }

        require(remainingValue == 0);

        weiForwarded = weiForwarded.add(msg.value);
    }
}
