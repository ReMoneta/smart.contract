pragma solidity ^0.4.0;


contract Crowdsale {

    uint256 public tokensSold;

    enum State {Unknown, Initializing, BeforeCrowdsale, InCrowdsale, Success, Finalized, Refunding}

    function externalContribution(address _contributor, uint256 _wei) public payable;

    function contribute(uint8 _v, bytes32 _r, bytes32 _s) public payable;

    function getState() public constant returns (State);

    function updateState() public;

    function internalContribution(address _contributor, uint256 _wei) internal;

}
