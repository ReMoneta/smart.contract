pragma solidity ^0.4.18;

import './ERC827.sol';


/// @title ERC827Token
/// @author Applicature
/// @notice ERC827 token standard
/// @dev implementation
contract ERC827Token is ERC827 {

    mapping (address => mapping (address => uint256)) public allowed;
    mapping(address => uint) public balances;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function ERC827Token (string _name, string _symbol, uint8 _decimals, uint256 total) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = total;
    }

    /// @return name of token
    function name() public view returns (string) {
        return name;
    }

    /// @return symbol of token
    function symbol() public view returns (string) {
        return symbol;
    }

    /// @return decimals of token
    function decimals() public view returns (uint8) {
        return decimals;
    }

    /// @return total supply of token
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @return current balance of address
    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    /// @notice allow to transfer funds
    function transfer(address to, uint256 value) public returns (bool) {
        return doTransfer(msg.sender, to, value);
    }

    /// @notice allow to transfer funds
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        return doTransfer(from, to, value);
    }

    /// @notice allow to approve transfer funds
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @return allowance for pair: owner, spender
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice allow to transfer funds
    /// ERC827 standart
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
        require(_to != address(this));
        require(transfer(_to, _value));
        require(_to.call(_data));
        return true;
    }

    /// @notice allow to transfer funds
    /// ERC827 standart
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
        require(_to != address(this));
        require(transferFrom(_from, _to, _value));
        require(_to.call(_data));
        return true;
    }

    /// @notice allow to approve transfer funds
    /// ERC827 standart
    function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
        require(_spender != address(this));
        require(approve(_spender, _value));
        require(_spender.call(_data));
        return true;
    }

    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

        if (_amount == 0) {
            return true;
        }

        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != 0) && (_to != address(this)));

        // If the amount being transfered is more than the balance of the
        //  account the transfer returns false
        var previousBalanceFrom = balanceOf(_from);
        if (previousBalanceFrom < _amount) {
            return false;
        }


        // First update the balance array with the new value for the address
        //  sending the tokens
        balances[_from] = previousBalanceFrom - _amount;

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        var previousBalanceTo = balanceOf(_to);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow

        balances[_to] = previousBalanceTo + _amount;

        // An event to make the transfer easy to find on the blockchain
        Transfer(_from, _to, _amount);

        return true;
    }

}

