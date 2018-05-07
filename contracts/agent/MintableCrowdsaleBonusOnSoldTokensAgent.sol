pragma solidity ^0.4.18;


import './CrowdsaleAgent.sol';
import '../crowdsale/Crowdsale.sol';
import '../token/erc20/MintableToken.sol';


/// @title MintableCrowdsaleBonusOnSoldTokensAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// if goal is reached then mint a bonus
/// un-pause tokens and disable minting on Crowdsale success
/// @dev implementation
contract MintableCrowdsaleBonusOnSoldTokensAgent is CrowdsaleAgent {


    Crowdsale public crowdsale;
    MintableToken public token;
    bool public goalAchieved;
    bool public bonusMinted;
    bool public _isInitialized;
    uint256 public tokensSoldGoal;
    address public bonusAddress;
    uint256 public bonusTokens;

    function MintableCrowdsaleBonusOnSoldTokensAgent(
        Crowdsale _crowdsale, MintableToken _token,
        uint256 _tokensSoldGoal, address _bonusAddress, uint256 _bonusTokens
    )
    public CrowdsaleAgent(_crowdsale)
    {
        crowdsale = _crowdsale;
        token = _token;

        tokensSoldGoal = _tokensSoldGoal;
        bonusAddress = _bonusAddress;
        bonusTokens = _bonusTokens;

        if (address(0) != address(_token) &&
        address(0) != address(_crowdsale) && address(0) != address(_bonusAddress) && _tokensSoldGoal > 0) {
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

    /// @notice Takes actions on contribution, if goal is reached then mint a bonus
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
    public onlyCrowdsale()
    {
        _contributor = _contributor;
        _weiAmount = _weiAmount;
        _tokens = _tokens;
        _bonus = _bonus;

        if (bonusMinted == false && crowdsale.tokensSold() > tokensSoldGoal) {
            bonusMinted = true;

            token.mint(bonusAddress, bonusTokens);
        }
    }

    /// @notice Takes actions on state change,
    /// un-pause tokens and disable minting on Crowdsale success
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        if (_state == Crowdsale.State.Success && goalAchieved == false) {
            goalAchieved = true;
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

