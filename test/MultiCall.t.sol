// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/MultiCall.sol";

contract MultiCallTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address multiCallAddr;
    address multiCallDestAddr;
    address deploymentAddr;
    address deploymentAddrM;
    bytes calldata1;
    bytes calldata2;
    uint256 num;
    uint256 timestamp;
    address[] targets;
    bytes[] calldatas;
    bytes[] results;

    MultiCall multiCall;
    MultiCallDest multiCallDest;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        multiCall = new MultiCall();
        multiCallAddr = address(multiCall);
        console.log("multiCallAddr:", multiCallAddr);

        multiCallDest = new MultiCallDest();
        multiCallDestAddr = address(multiCallDest);
        console.log("multiCallDestAddr:", multiCallDestAddr);
    }

    function test1() public {
        console.log("---------== test1");
        vm.warp(1 days);
        (num, timestamp) = multiCallDest.func1();
        console.log("num1:", num, ", timestamp1:", timestamp);
        (num, timestamp) = multiCallDest.func2();
        console.log("num2:", num, ", timestamp2:", timestamp);

        calldata1 = multiCallDest.getFuncData(1);
        calldata2 = multiCallDest.getFuncData(2);
        console.log("calldata1:");
        console.logBytes(calldata1);
        console.log("calldata2:");
        console.logBytes(calldata2);

        targets.push(multiCallDestAddr);
        targets.push(multiCallDestAddr);
        calldatas.push(calldata1);
        calldatas.push(calldata2);
        //vm.warp(1 days);
        results = multiCall.multiCall(targets, calldatas);
        console.log("results length:", results.length);
        console.logBytes(results[0]);
        // uint_num+uint_timestamp: 0x00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000015180

        console.logBytes(results[1]);
        //assertEq(deploymentAddr, deploymentAddrM);
    }
}
