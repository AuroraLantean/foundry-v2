// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/MultiDelegatecall.sol";

contract MultiDelegateCallTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address multiDelegatecallAddr;
    address multiDelegatecallDestAddr;
    address deploymentAddr;
    address deploymentAddrM;
    bytes calldata1;
    bytes calldata2;
    bytes calldataMint;
    uint256 num;
    uint256 timestamp;
    uint256 argX;
    uint256 argY;
    uint256 ethSent;
    uint256 ethBalc;
    address[] targets;
    bytes[] calldatas;
    bytes[] results;

    MultiDelegatecallDest multiDelegatecallDest;
    Helper helper;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        helper = new Helper();

        multiDelegatecallDest = new MultiDelegatecallDest();
        multiDelegatecallDestAddr = address(multiDelegatecallDest);
        console.log("multiDelegatecallDestAddr:", multiDelegatecallDestAddr);
    }

    function test1() public {
        console.log("---------== test1");
        vm.warp(1 days);
        argX = 7;
        argY = 8;
        calldata1 = helper.getFunc1Data(argX, argY);
        calldata2 = helper.getFunc2Data();
        console.log("calldata1:");
        console.logBytes(calldata1);
        console.log("calldata2:");
        console.logBytes(calldata2);

        calldatas.push(calldata1);
        calldatas.push(calldata2);
        vm.expectEmit(true, true, false, true);
        emit Log(alice, "func1", argX + argY);
        emit Log(alice, "func2", 2);

        vm.prank(alice);
        results = multiDelegatecallDest.multiDelegatecall(calldatas);
        console.logBytes(results[0]);
        console.logBytes(results[1]);
        //assertEq(deploymentAddr, deploymentAddrM);
    }

    function test2() public {
        console.log("---------== test2");
        calldataMint = helper.getMintData();
        console.log("calldataMint:");
        console.logBytes(calldataMint);

        calldatas.push(calldataMint);
        calldatas.push(calldataMint);
        calldatas.push(calldataMint);
        //vm.expectEmit(true, true, false, true);
        //emit Log(alice, "mint", argX+argY);

        ethSent = 1 ether;
        vm.prank(alice);
        results = multiDelegatecallDest.multiDelegatecall{value: ethSent}(calldatas);
        console.logBytes(results[0]);
        console.logBytes(results[1]);
        console.logBytes(results[2]);

        ethBalc = multiDelegatecallDest.balanceOf(alice);
        console.log("ethBalc: ", ethBalc, ", results.length:", results.length);
        assertEq(ethBalc, ethSent * (results.length));
    }
}
