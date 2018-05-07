pragma solidity ^0.4.18;


import './CrowdsaleAgent.sol';
import '../crowdsale/Crowdsale.sol';
import '../token/PausableToken.sol';
import '../allocator/TokenAllocator.sol';


/// @title PausableCrowdsaleBonusOnSoldTokensAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// if goal is reached then mint a bonus
/// un-pause token and disable minting on Crowdsale success
/// @dev implementation
contract PausableCrowdsaleBonusOnSoldTokensAgent is CrowdsaleAgent {


    Crowdsale public crowdsale;
    PausableToken public token;
    TokenAllocator public tokenAllocator;
    bool public goalAchieved;
    bool public bonusTransfered;
    uint256 public tokensSoldGoal;
    address public bonusAddress;
    uint256 public bonusTokens;
    bool public _isInitialized;

    function PausableCrowdsaleBonusOnSoldTokensAgent(
        Crowdsale _crowdsale, PausableToken _token, TokenAllocator _tokenAllocator,
        uint256 _tokensSoldGoal, address _bonusAddress, uint256 _bonusTokens
    )
    public CrowdsaleAgent(_crowdsale)
    {
        crowdsale = _crowdsale;
        token = _token;
        tokenAllocator = _tokenAllocator;

        tokensSoldGoal = _tokensSoldGoal;
        bonusAddress = _bonusAddress;
        bonusTokens = _bonusTokens;

        if (address(0) != address(_token) &&
        address(0) != address(tokenAllocator) &&
        address(0) != address(_crowdsale) && address(0) != _bonusAddress && _tokensSoldGoal > 0) {
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

    /// @notice Takes actions on contribution, if goal is reached then transfer bonus
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
    public onlyCrowdsale()
    {
        _contributor = _contributor;
        _weiAmount = _weiAmount;
        _tokens = _tokens;
        _bonus = _bonus;

        if (bonusTransfered == false && crowdsale.tokensSold() > tokensSoldGoal) {
            bonusTransfered = true;

            tokenAllocator.allocate(bonusAddress, bonusTokens);
        }
    }

    /// @notice Takes actions on state change,
    /// un-pause tokens on Crowdsale success
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        if (_state == Crowdsale.State.Success && goalAchieved == false) {
            goalAchieved = true;

            token.unpause();
        }
    }
}

