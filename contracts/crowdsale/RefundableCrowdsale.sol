pragma solidity ^0.4.18;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../agent/CrowdsaleAgent.sol';
import '../allocator/TokenAllocator.sol';
import '../contribution/ContributionForwarder.sol';
import '../pricing/PricingStrategy.sol';
import './HardCappedCrowdsale.sol';


/// @title RefundableCrowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
/// with hard and soft limits
contract RefundableCrowdsale is HardCappedCrowdsale {


    using SafeMath for uint256;

    uint256 public softCap;
    mapping(address => uint256) public contributorsWei;
    address[] public contributors;

    event Refund(address _holder, uint256 _wei, uint256 _tokens);

    function RefundableCrowdsale(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous,
        uint256 _softCap,
        uint256 _hardCap

    )
    public
    HardCappedCrowdsale(
        _allocator, _contributionForwarder, _pricingStrategy,
        _startDate, _endDate,
        _allowWhitelisted, _allowSigned, _allowAnonymous, _hardCap
    )
    {
        softCap = _softCap;
    }

    /// @return Crowdsale state
    function getState() public constant returns (State) {
        State state = super.getState();

        if (state == State.Success) {
            if (tokensSold >= softCap) {
                return State.Success;
            }
        }

        return state;
    }

    /// @notice refund ethers to contributor
    function refund() public {
        internalRefund(msg.sender);
    }

    /// @notice refund ethers to delegate
    function delegatedRefund(address _address) public {
        internalRefund(_address);
    }

    /// @notice auto refund to all contributors
    function autoRefund(uint256 _from, uint256 _till) public {
        require(contributors.length > _from && contributors.length < _till);

        for (uint256 i = _from; i < _till; i++) {
            internalRefund(contributors[i]);
        }
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        require(block.timestamp >= startDate && block.timestamp <= endDate);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei);

        require(tokens < tokensAvailable);
        require(hardCap > tokensSold.add(tokens));

        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        // transfer only if softcap is reached
        if (tokensSold >= softCap) {
            if (msg.value > 0) {
                contributionForwarder.forward.value(msg.value)();
            }
        } else {
            // store contributor if it is not stored before
            if (contributorsWei[_contributor] == 0) {
                contributors.push(_contributor);
            }
            contributorsWei[_contributor] = contributorsWei[_contributor].add(msg.value);
        }

        Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

    function internalRefund(address _holder) internal {
        require(block.timestamp > endDate);
        require(tokensSold < softCap);

        uint256 value = contributorsWei[_holder];

        require(value > 0);

        contributorsWei[_holder] = 0;

        _holder.transfer(value);

        // @TODO: burn tokens
        Refund(_holder, value, 0);
    }
}

