pragma solidity ^0.4.23;


/// @title ERC223
/// @author Applicature
/// @notice ERC223 token standard
/// @dev Base class
contract ERC223 {

    uint public _totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function name() public view returns (string _name);

    function symbol() public view returns (string _symbol);

    function decimals() public view returns (uint8 _decimals);

    function totalSupply() public view returns (uint256 _supply);

    function transfer(address to, uint256 value) public returns (bool);

    function transfer(address to, uint256 value, bytes data) public returns (bool);

    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

}

