// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/TimeLock.sol";

contract timeLockTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address timeLockAddr;
    address destinationAddr;
    address addr1;
    address addr1M;
    bytes calldata1;
    bytes errdata;
    bytes calldataMint;
    bytes32 txId;
    uint256 num;
    uint256 ethValue;
    uint256 ethBalc;
    uint256 executeTimeMin;
    uint256 timeNow;
    uint256 minDelay;
    uint256 maxDelay;
    uint256 time;
    uint256 executionPeriod;
    uint256 deploymtTime;
    string funcName;

    TimeLock timelock;
    Destination destination;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        minDelay = 1 weeks;
        maxDelay = 30 days;
        executionPeriod = 3 days;
        vm.startPrank(alice);
        timelock = new TimeLock(minDelay, maxDelay, executionPeriod);
        timeLockAddr = address(timelock);
        console.log("timeLockAddr:", timeLockAddr);

        destination = new Destination(timeLockAddr);
        destinationAddr = address(destination);
        console.log("destinationAddr:", destinationAddr);
        vm.stopPrank();
    }

    function test1() public {
        console.log("---------== test1");
        ethValue = 0;
        funcName = "dest1()";
        calldata1 = "";
        deploymtTime = timelock.getTime();
        executeTimeMin = deploymtTime + minDelay;
        vm.prank(alice);
        txId = timelock.addTxId(destinationAddr, ethValue, funcName, calldata1, executeTimeMin);
        console.log("txId:");
        console.logBytes32(txId);

        num = destination.num();
        assertEq(num, 0);

        time = executeTimeMin - 1;
        vm.warp(time);
        errdata = abi.encodeWithSelector(TimeLock.TimeNotYetError.selector, time, executeTimeMin);
        //vm.expectRevert("not authorized");
        //vm.expectRevert(TimeLock.TimeNotYetError.selector);
        console.logBytes(errdata);
        vm.expectRevert(errdata);
        vm.prank(alice);
        timelock.execute(destinationAddr, ethValue, funcName, calldata1, executeTimeMin);

        time = executeTimeMin + executionPeriod + 1;
        vm.warp(time);
        errdata = abi.encodeWithSelector(TimeLock.TimeExpiredError.selector, time, executeTimeMin + executionPeriod);
        console.logBytes(errdata);
        vm.expectRevert(errdata);
        vm.prank(alice);
        timelock.execute(destinationAddr, ethValue, funcName, calldata1, executeTimeMin);

        time = executeTimeMin + executionPeriod;
        vm.warp(time);
        errdata = abi.encodeWithSelector(TimeLock.TimeExpiredError.selector, time, executeTimeMin + executionPeriod);
        console.logBytes(errdata);
        //vm.expectRevert(errdata);
        vm.prank(alice);
        timelock.execute(destinationAddr, ethValue, funcName, calldata1, executeTimeMin);

        num = destination.num();
        assertEq(num, 1);
    }
}
