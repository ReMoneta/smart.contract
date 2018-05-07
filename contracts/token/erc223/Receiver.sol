pragma solidity ^0.4.18;

contract Receiver {
    bytes public lastData;
    address public lastFrom;

    function tokenFallback(address _from, uint256 _value, bytes _data)
    public returns (bool) {
        require(_value % 1000 == 0);

        lastData = _data;
        lastFrom = _from;

        return true;
    }
}
