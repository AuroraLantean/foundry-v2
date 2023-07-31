// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Library.sol";

contract LibraryTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 num;
    uint256 numM;
    uint256 inputValue = 13;
    uint256 etherValue;
    address payable addr1;
    address addr2;
    TestArray testArray;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        testArray = new TestArray();
        calleeAddr = address(testArray);
    }

    function test1() public {
        console.log("---------== test1");
        numM = testArray.testArrayFindIndex(1);
        console.log("numM", numM);
        assertEq(numM, 3);
    }
}
