pragma solidity ^0.4.23;


import './CrowdsaleMultipleAgent.sol';
import '../crowdsale/Crowdsale.sol';
import '../token/erc20/MintableToken.sol';


/// @title MintableMultipleCrowdsaleOnSuccessAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// un-pause tokens and disable minting on Crowdsale success
/// @dev implementation
contract MintableMultipleCrowdsaleOnSuccessAgent is CrowdsaleMultipleAgent {


    MintableToken public token;
    bool public _isInitialized;

    constructor(Crowdsale[] _crowdsales, MintableToken _token)
    public CrowdsaleMultipleAgent(_crowdsales)
    {
        token = _token;

        if (address(0) != address(_token)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return _isInitialized;
    }

    /// @notice Takes actions on contribution
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
    public onlyCrowdsale() {
        _contributor = _contributor;
        _weiAmount = _weiAmount;
        _tokens = _tokens;
        _bonus = _bonus;
        // TODO: add impl
    }

    /// @notice Takes actions on state change,
    /// un-pause tokens and disable minting on Crowdsale success
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        if (_state == Crowdsale.State.Success || _state == Crowdsale.State.Finalized) {
            token.disableMinting();
        }
    }
    /// @notice Takes actions on refund
    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned) {
        _contributor = _contributor;
        _tokens = _tokens;
        burned = burned;
        // TODO: add impl
    }
}

