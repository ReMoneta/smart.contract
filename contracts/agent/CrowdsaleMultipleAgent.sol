pragma solidity ^0.4.18;


import './Agent.sol';
import '../crowdsale/Crowdsale.sol';


/// @title CrowdsaleAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract CrowdsaleMultipleAgent is Agent {


//    Crowdsale public crowdsales;
    mapping(address => bool) public crowdsales;
    bool public _isInitialized;

    modifier onlyCrowdsale() {
        require(crowdsales[msg.sender] == true);
        _;
    }

    function CrowdsaleMultipleAgent(Crowdsale[] _crowdsales) public {

        for (uint256 i = 0; i < _crowdsales.length; i++) {
            require(_crowdsales[i] != address(0));
            crowdsales[_crowdsales[i]] = true;
        }

        if (_crowdsales.length > 0) {
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

    /// @notice Takes actions on refund
    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned) {
        _contributor = _contributor;
        _tokens = _tokens;
        burned = burned;
        // TODO: add impl
    }
}

