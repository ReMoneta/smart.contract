pragma solidity ^0.4.18;

import './Receiver.sol';
import './ERC223.sol';

/// @title ERC223Token
/// @author Applicature
/// @notice ERC223 token
/// @dev implementation
contract ERC223Token is ERC223 {

    mapping(address => uint) public balances;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    function ERC223Token (string _name, string _symbol, uint8 _decimals, uint256 total) public {
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
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    /// @notice allow a user or another contract to transfer funds
    function transfer(address _to, uint _value, bytes _data, string _customFallback) public returns (bool success) {

        _customFallback = _customFallback;
        if (isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = balanceOf(msg.sender) - _value;
            balances[_to] = balanceOf(_to) + _value;
            assert(_to.call.value(0)(bytes4(keccak256(_customFallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    /// @notice allow a user or another contract to transfer funds
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    /// @notice allow a user or another contract to transfer funds
    /// Standard function transfer similar to ERC20 transfer with no _data
    /// Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) public returns (bool success) {

        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }

    /// @notice assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    /// @notice function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender) - _value;
        balances[_to] = balanceOf(_to) + _value;
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    /// @notice function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender) - _value;
        balances[_to] = balanceOf(_to) + _value;
        Receiver receiver = Receiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

}
