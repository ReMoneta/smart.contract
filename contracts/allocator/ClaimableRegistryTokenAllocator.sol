pragma solidity ^0.4.23;


import './../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import './TokenAllocator.sol';
import '../token/ClaimableToken.sol';


/// @title ClaimableRegistryTokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev implementation
contract ClaimableRegistryTokenAllocator is TokenAllocator {


    using SafeMath for uint256;

    uint256 public maxSupply;
    uint256 public allocatedTokens;
    address[] public holders;
    uint256 public holdersCount;
    mapping(address => uint256) public claimableHolders;
    ClaimableToken public token;

    constructor(ClaimableToken _token, uint256 _maxSupply) public {
        require(_maxSupply > 0);
        maxSupply = _maxSupply;
        token = _token;
    }

    function setToken(ClaimableToken _token) public onlyOwner {
        token = _token;
    }

    /// @return available tokens
    function tokensAvailable() public constant returns (uint256) {
        return maxSupply.sub(allocatedTokens);
    }

    /// @notice transfer tokens on delegate account
    function delegatedClaim(address _holder) public {
        internalClaim(_holder);
    }

    /// @notice transfer tokens on holder account
    function claim() public {
        internalClaim(msg.sender);
    }

    /// @notice transfer tokens on holder account
    function allocate(address _holder, uint256 _tokens) public onlyCrowdsale() {
        internalAllocate(_holder, _tokens);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public constant returns (bool) {
        return true;
    }

    function internalClaim(address _holder) internal {
        require(token != address(0));

        uint256 holderBalance = claimableHolders[_holder];

        require(holderBalance > 0);

        claimableHolders[_holder] = 0;

        token.claim(_holder, holderBalance);
    }

    function internalAllocate(address _holder, uint256 _tokens) internal {
        require(_tokens > 0);

        if (claimableHolders[_holder] == 0) {
            holders.push(_holder);
            holdersCount = holdersCount.add(1);
        }

        allocatedTokens = allocatedTokens.add(_tokens);

        claimableHolders[_holder] = claimableHolders[_holder].add(_tokens);
    }

}

