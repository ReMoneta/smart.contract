pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './CrowdsaleImpl.sol';
import '../allocator/TokenAllocator.sol';
import '../contribution/ContributionForwarder.sol';
import '../pricing/PricingStrategy.sol';
import '../agent/CrowdsaleAgent.sol';


/// @title HardCappedCrowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
/// with hard limit
contract HardCappedCrowdsale is CrowdsaleImpl {


    using SafeMath for uint256;

    uint256 public hardCap;

    function HardCappedCrowdsale(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous,
        uint256 _hardCap
    )
    public
    CrowdsaleImpl(
        _allocator,
        _contributionForwarder,
        _pricingStrategy,
        _startDate,
        _endDate,
        _allowWhitelisted,
        _allowSigned,
        _allowAnonymous
    )
    {
        hardCap = _hardCap;
    }

    /// @return Crowdsale state
    function getState() public constant returns (State) {
        State state = super.getState();

        if (state == State.InCrowdsale) {
            if (tokensSold == hardCap) {
                return State.Success;
            }
        }

        return state;
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        require(getState() == State.InCrowdsale);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, msg.value, collectedWei);

        require(tokens < tokensAvailable);
        require(hardCap > tokensSold.add(tokens));

        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        if (msg.value > 0) {
            contributionForwarder.forward.value(msg.value)();
        }

        Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }
}

