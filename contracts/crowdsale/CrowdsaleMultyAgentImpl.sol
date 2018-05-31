pragma solidity ^0.4.23;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../allocator/TokenAllocator.sol';
import '../contribution/ContributionForwarder.sol';
import '../pricing/PricingStrategy.sol';
import '../agent/CrowdsaleMultipleAgent.sol';
import '../Ownable.sol';
import './Crowdsale.sol';


/// @title Crowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
contract CrowdsaleMultyAgentImpl is Crowdsale, Ownable {


    using SafeMath for uint256;

    State public currentState;
    TokenAllocator public allocator;
    ContributionForwarder public contributionForwarder;
    PricingStrategy public pricingStrategy;
    CrowdsaleMultipleAgent public crowdsaleAgent;
    bool public finalized;
    uint256 public startDate;
    uint256 public endDate;
    bool public allowWhitelisted;
    bool public allowSigned;
    bool public allowAnonymous;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public signers;
    mapping(address => bool) public externalContributionAgents;

    event Contribution(address _contributor, uint256 _wei, uint256 _tokensExcludingBonus, uint256 _bonus);

    constructor(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous
    )
    public
    {
        allocator = _allocator;
        contributionForwarder = _contributionForwarder;
        pricingStrategy = _pricingStrategy;

        startDate = _startDate;
        endDate = _endDate;

        allowWhitelisted = _allowWhitelisted;
        allowSigned = _allowSigned;
        allowAnonymous = _allowAnonymous;

        currentState = State.Unknown;
    }

    /// @notice default payable function
    function() public payable {
        require(allowWhitelisted || allowAnonymous);

        if (!allowAnonymous) {
            if (allowWhitelisted) {
                require(whitelisted[msg.sender]);
            }
        }

        internalContribution(msg.sender, msg.value);
    }

    /// @notice update crowdsale agent
    function setCrowdsaleAgent(CrowdsaleMultipleAgent _crowdsaleAgent) public onlyOwner {
        crowdsaleAgent = _crowdsaleAgent;
    }

    /// @notice allows external user to do contribution
    function externalContribution(address _contributor, uint256 _wei) public payable {
        require(externalContributionAgents[msg.sender]);
        internalContribution(_contributor, _wei);
    }

    /// @notice update external contributor
    function addExternalContributor(address _contributor) public onlyOwner {
        externalContributionAgents[_contributor] = true;
    }

    /// @notice update external contributor
    function removeExternalContributor(address _contributor) public onlyOwner {
        externalContributionAgents[_contributor] = false;
    }

    /// @notice update signer
    function addSigner(address _signer) public onlyOwner {
        signers[_signer] = true;
    }

    /// @notice update signer
    function removeSigner(address _signer) public onlyOwner {
        signers[_signer] = false;
    }

    /// @notice allows to do signed contributions
    function contribute(uint8 _v, bytes32 _r, bytes32 _s) public payable {
        address recoveredAddress = verify(msg.sender, _v, _r, _s);
        require(signers[recoveredAddress]);
        internalContribution(msg.sender, msg.value);
    }

    /// @notice check sign
    function verify(address _sender, uint8 _v, bytes32 _r, bytes32 _s) public constant returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(this, _sender));

        bytes memory prefix = '\x19Ethereum Signed Message:\n32';

        return ecrecover(keccak256(abi.encodePacked(prefix, hash)), _v, _r, _s);
    }

    /// @return Crowdsale state
    function getState() public constant returns (State) {
        if (finalized) {
            return State.Finalized;
        } else if (allocator.isInitialized() == false) {
            return State.Initializing;
        } else if (contributionForwarder.isInitialized() == false) {
            return State.Initializing;
        } else if (pricingStrategy.isInitialized() == false) {
            return State.Initializing;
        } else if (block.timestamp < startDate) {
            return State.BeforeCrowdsale;
        } else if (block.timestamp >= startDate && block.timestamp <= endDate) {
            return State.InCrowdsale;
        } else if (block.timestamp > endDate) {
            return State.Success;
        }

        return State.Unknown;
    }

    /// @notice Crowdsale state
    function updateState() public {
        State state = getState();

        if (currentState != state) {
            if (crowdsaleAgent != address(0)) {
                crowdsaleAgent.onStateChange(state);
            }

            currentState = state;
        }
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
        tokensSold = tokensSold.add(tokens);
        allocator.allocate(_contributor, tokens);

        if (msg.value > 0) {
            contributionForwarder.forward.value(msg.value)();
        }

        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

}

