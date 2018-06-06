pragma solidity ^0.4.23;

import './agent/MintableCrowdsaleOnSuccessAgent.sol';
import './REMToken.sol';


contract REMAgent is MintableCrowdsaleOnSuccessAgent {


    REMToken public token;

    constructor(Crowdsale _crowdsale, REMToken _token)
    public MintableCrowdsaleOnSuccessAgent(_crowdsale, _token)
    {
        token = _token;

        if (address(0) != address(_token)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
    public onlyCrowdsale() {
        _bonus = _bonus;
        _weiAmount = _weiAmount;
        token.log(_contributor, _tokens, block.timestamp);
    }

    /// @notice Takes actions on refund
    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned) {
        _tokens = _tokens;
        if (Crowdsale(msg.sender).getState() == Crowdsale.State.Refunding) {
            burned = token.burn(_contributor);
        }
    }
}

