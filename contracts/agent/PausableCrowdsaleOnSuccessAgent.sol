pragma solidity ^0.4.18;


import './CrowdsaleAgent.sol';
import '../crowdsale/Crowdsale.sol';
import '../token/PausableToken.sol';


/// @title PausableCrowdsaleOnSuccessAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// un-pause tokens on Crowdsale success
/// @dev implementation
contract PausableCrowdsaleOnSuccessAgent is CrowdsaleAgent {


    Crowdsale public crowdsale;
    PausableToken public token;
    bool public _isInitialized;

    function PausableCrowdsaleOnSuccessAgent(Crowdsale _crowdsale, PausableToken _token)
    public CrowdsaleAgent(_crowdsale)
    {
        crowdsale = _crowdsale;
        token = _token;
        if (address(0) != address(_token) && address(0) != address(_crowdsale)) {
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
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus) public onlyCrowdsale() {
        _contributor = _contributor;
        _weiAmount = _weiAmount;
        _tokens = _tokens;
        _bonus = _bonus;
        // TODO: add impl
    }

    /// @notice Takes actions on state change,
    /// un-pause tokens on Crowdsale success
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        if (_state == Crowdsale.State.Success) {
            token.unpause();
        }
    }
}

