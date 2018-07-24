pragma solidity ^0.4.23;

import './agent/MintableCrowdsaleOnSuccessAgent.sol';
import './RETToken.sol';


contract RETAgent is MintableCrowdsaleOnSuccessAgent {


    constructor(Crowdsale _crowdsale, RETToken _token) public MintableCrowdsaleOnSuccessAgent(_crowdsale, _token) {
        if (address(0) != address(_token) && address(0) != address(_crowdsale)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    function onContribution(address _contributor, uint256, uint256 _tokens, uint256)
    public onlyCrowdsale() {
        RETToken(token).log(_contributor, _tokens, block.timestamp);
    }

    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        _state = _state;
    }

    /// @notice Takes actions on refund
    function onRefund(address, uint256) public onlyCrowdsale() returns (uint256 burned) {
        require(false);
        return burned;
    }
}

