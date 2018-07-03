pragma solidity ^0.4.23;

import './Agent.sol';
import '../crowdsale/Crowdsale.sol';


/// @title CrowdsaleAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract CrowdsaleAgent is Agent {


    Crowdsale public crowdsale;
    bool public _isInitialized;

    modifier onlyCrowdsale() {
        require(msg.sender == address(crowdsale));
        _;
    }

    constructor(Crowdsale _crowdsale) public {
        crowdsale = _crowdsale;

        if (address(0) != address(_crowdsale)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    function isInitialized() public constant returns (bool) {
        return _isInitialized;
    }

    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
        public onlyCrowdsale();

    function onStateChange(Crowdsale.State _state) public onlyCrowdsale();

    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned);
}

