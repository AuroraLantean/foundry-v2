// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    address dest;
    address[] owners;
    uint256 numConfirmationReq;
    uint256 numConfirmationReqM;
    bytes data;
    uint256 txnCount;
    address toM;
    uint256 valueM;
    bytes dataM;
    bool isExecutedM;
    uint256 numConfM;
    uint256 numInput;
    uint256 num;
    uint256 numM;
    uint256 etherValue;
    address payable addr1;
    address addr2;
    MultiSigWallet caller;
    DestCtrt callee;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;
    bool isTrue;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        owners.push(alice);
        owners.push(bob);
        owners.push(charlie);
        numConfirmationReq = 2;
        vm.prank(alice);
        caller = new MultiSigWallet(owners, numConfirmationReq);
        callerAddr = address(caller);

        callee = new DestCtrt();
        calleeAddr = address(callee);
    }

    function test1() public {
        console.log("---------== test1");
        numConfirmationReqM = caller.numConfirmationsRequired();
        console.log("numConfirmationReq:", numConfirmationReq);
        assertEq(numConfirmationReq, numConfirmationReqM);

        dest = calleeAddr;
        etherValue = 789;
        numInput = 123;
        data = abi.encodeWithSignature("callMe(uint256)", numInput);
        console.logBytes(data);

        vm.prank(alice);
        caller.submitTransaction(dest, etherValue, data);

        vm.prank(alice);
        (bool ok,) = callerAddr.call{value: 3 ether}("");
        assertEq(ok, true);

        txnCount = caller.getTransactionCount();
        assertEq(txnCount, 1);

        (toM, valueM, dataM, isExecutedM, numConfM) = caller.getTransaction(0);
        console.log("toM:", toM);
        console.log("valueM:", valueM);
        console.log("isExecutedM:", isExecutedM);
        console.log("numConfM:", numConfM);
        console.logBytes(dataM);
        assertEq(toM, dest);
        assertEq(valueM, etherValue);
        assertEq(dataM, data);
        assertEq(isExecutedM, false);
        assertEq(numConfM, 0);

        vm.prank(bob);
        caller.confirmTransaction(0);
        vm.prank(charlie);
        caller.confirmTransaction(0);
        (toM, valueM, dataM, isExecutedM, numConfM) = caller.getTransaction(0);
        console.log("numConfM:", numConfM);
        assertEq(numConfM, 2);

        num = callee.num();
        console.log("num:", num);
        assertEq(num, 0);

        vm.prank(alice);
        caller.executeTransaction(0);

        num = callee.num();
        console.log("num:", num);
        assertEq(num, numInput);

        ethBalc = callee.getBalance();
        console.log("ethBalc:", ethBalc);
        assertEq(ethBalc, etherValue);
    }
}
