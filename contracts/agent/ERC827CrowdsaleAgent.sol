pragma solidity ^0.4.18;


import './CrowdsaleAgent.sol';
import '../crowdsale/Crowdsale.sol';
import '../token/erc827/ERC827Token.sol';


/// @title ERC827CrowdsaleAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev implementation
contract ERC827CrowdsaleAgent is CrowdsaleAgent {

    Crowdsale public crowdsale;
    ERC827Token public token;
    bool public _isInitialized;

    function ERC827CrowdsaleAgent(Crowdsale _crowdsale, ERC827Token _token)
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
    /// extend with your functionality
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
    public onlyCrowdsale() {
        _contributor = _contributor;
        _weiAmount = _weiAmount;
        _tokens = _tokens;
        _bonus = _bonus;
        // TODO: add impl
    }

    /// @notice Takes actions on state change,
    /// extend with your functionality
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        _state = _state;
        // TODO: add impl
    }

    /// @notice Takes actions on refund
    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned) {
        _contributor = _contributor;
        _tokens = _tokens;
        burned = burned;
        // TODO: add impl
    }

}
