// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/UgTransparent.sol";

contract UgTransparentTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address addr1;
    address addr1M;
    address to;
    bytes data_encodeCell;
    bytes data_encodeWithSignature;
    bytes data_encodeWithSelector;
    uint256 ethSent;
    uint256 ethBalc;
    uint256 count;
    uint256 countM;

    ProxyBuggy proxyBuggy;
    CounterV1 counterV1;
    CounterV2 counterV2;
    ProxyFixed proxyFixed;
    address proxyBuggyAddr;
    address proxyFixedAddr;
    address counterV1Addr;
    address counterV2Addr;
    address impAddr;
    address impAddrM;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);

        proxyBuggy = new ProxyBuggy();
        proxyBuggyAddr = address(proxyBuggy);
        console.log("proxyBuggyAddr:", proxyBuggyAddr);

        proxyFixed = new ProxyFixed();
        proxyFixedAddr = address(proxyFixed);
        console.log("proxyFixedAddr:", proxyFixedAddr);

        counterV1 = new CounterV1();
        counterV1Addr = address(counterV1);
        console.log("counterV1Addr:", counterV1Addr);

        counterV2 = new CounterV2();
        counterV2Addr = address(counterV2);
        console.log("counterV2Addr:", counterV2Addr);
    }

    function testProxyBuggy() public {
        console.log("---------== test ProxyBuggy");
        impAddr = counterV1Addr;
        proxyBuggy.upgradeTo(impAddr);
        impAddrM = proxyBuggy.implementation();
        assertEq(impAddrM, impAddr);

        //CounterV1 is loaded at proxyBuggy address
        count = 0;
        counterV1 = CounterV1(proxyBuggyAddr);
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count);

        console.log("check1");
        counterV1.inc();
        count += 1;
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count);

        impAddrM = proxyBuggy.implementation();
        assertEq(impAddrM, impAddr);
    }

    function testProxyFixed() public {
        console.log("---------== test ProxyFixed");
        impAddr = counterV1Addr;
        proxyFixed.upgradeTo(impAddr);
        impAddrM = proxyFixed.implementation();
        assertEq(impAddrM, impAddr);

        count = 0;
        counterV1 = CounterV1(proxyFixedAddr); //Use V1
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count);

        console.log("to call inc()");
        counterV1.inc();
        counterV1.inc();
        count += 2;
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count);

        //------------------==
        console.log("---------== Upgrade to CounterV2");
        impAddr = counterV2Addr;
        proxyFixed.upgradeTo(impAddr);
        impAddrM = proxyFixed.implementation();
        assertEq(impAddrM, impAddr);

        counterV2 = CounterV2(proxyFixedAddr); //User V2
        countM = counterV2.count();
        console.log("countM", countM);
        assertEq(countM, count); //the same as the count at CounterV1

        console.log("to call dec()");
        counterV2.dec();
        counterV2.dec();
        count -= 2;
        countM = counterV2.count();
        console.log("countM", countM);
        assertEq(countM, count);
    }
}
