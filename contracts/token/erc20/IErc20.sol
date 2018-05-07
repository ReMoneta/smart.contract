pragma solidity ^0.4.18;

/// @title IErc20
/// @author Applicature
/// @notice standart ERC20
/// @dev Base class
contract IErc20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _holder) public view returns (uint256);

    function allowance(address _holder, address _delegate) public view returns (uint256);

    function approve(address _to, uint256 _tokens) public returns (bool);

    function transfer(address _to, uint256 _tokens) public returns (bool);

    function transferFrom(address _holder, address _to, uint256 _tokens) public returns (bool);

    // internal methods
    function setTotalSupply(uint256 _totalSupply) internal;

    function setBalance(address _holder, uint256 _balance) internal;
}
