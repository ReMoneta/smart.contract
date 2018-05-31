pragma solidity ^0.4.23;

/// @title ClaimableToken
/// @author Applicature
/// @notice allow to claim tokens
/// @dev Base class
contract ClaimableToken {
    mapping(address => bool) public claimableDelegates;

    modifier onlyClaimableDelegates () {
        require(claimableDelegates[msg.sender]);
        _;
    }

    function claim(address _holder, uint256 _tokens) public onlyClaimableDelegates();
}
