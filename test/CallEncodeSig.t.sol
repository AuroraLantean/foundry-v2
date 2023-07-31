// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/CallEncodeSig.sol";

contract CallEncodeSigTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 num;
    uint256 numM;
    uint256 inputValue = 13;
    uint256 etherValue;
    address payable addr1;
    address addr2;
    Callee callee;
    Caller caller;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        callee = new Callee();
        calleeAddr = address(callee);
        //pwallet = new PayableWallet{value: 1e18}(); //from address(this)
        caller = new Caller();
        callerAddr = address(caller);
    }

    function test1() public {
        console.log("---------== test1");
        etherValue = 973000; //MUST BE >= THE ETHER AMOUNT SPECIFIED IN THE CALLED FUNCTION!!!
        num = 123;
        mesg = "mesg1: can you read?";

        //vm.prank(alice);//not effective because we use low level call
        caller.callFoo{value: etherValue}(calleeAddr, mesg, num);
        ethBalc = calleeAddr.balance;
        mesgM = callee.mesg();
        numM = callee.num();
        console.log("outputs:", ethBalc, mesgM, numM);
        assertEq(etherValue, ethBalc);
        assertEq(mesgM, mesg);
        assertEq(numM, num);

        caller.callFuncNotExisting{value: etherValue}(calleeAddr);
        ethBalc = calleeAddr.balance;
        mesgM = callee.mesg();
        numM = callee.num();
        console.log("outputs:", ethBalc, mesgM, numM);
        assertEq(etherValue * 2, ethBalc);
        assertEq(mesgM, "fallback");
    }
}
