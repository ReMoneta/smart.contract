pragma solidity ^0.4.18;


/// @title ERC827
/// @author Applicature
/// @notice ERC827 token standard
/// @dev Base class
contract ERC827 {
    uint public _totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function name() public view returns (string _name);

    function symbol() public view returns (string _symbol);

    function decimals() public view returns (uint8 _decimals);

    function totalSupply() public view returns (uint256 _supply);

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool);

    function approve(address _spender, uint256 _value, bytes _data) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
