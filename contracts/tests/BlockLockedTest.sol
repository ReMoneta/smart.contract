pragma solidity ^0.4.0;


import '../BlockLocked.sol';


contract BlockLockedTest is BlockLocked {


    // leave it in case the tests fail on someone machine
    event Test(uint256 _blockNumber);

    function BlockLockedTest(uint256 _blockNumber) public BlockLocked(_blockNumber) {

    }

    function() public payable {

    }

    function shouldBeLocked() public isBlockLocked(true) returns (bool) {
        Test(block.number);
        return true;
    }

    function shouldBeUnLocked() public isBlockLocked(false) returns (bool) {
        Test(block.number);
        return true;
    }

}

