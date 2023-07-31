// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/UgTransparent2.sol";

contract UgTransparent2Test is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address addr1;
    address addr1M;
    address admin;
    address adminM;
    address outAddr;
    bytes32 b32a;
    uint256 ethSent;
    uint256 ethBalc;
    uint256 count;
    uint256 countM;

    TestSlot testSlot;
    CounterV1 counterV1;
    CounterV2 counterV2;
    Proxy proxy;
    ProxyAdmin proxyAdmin;
    address testSlotAddr;
    address proxyAddr;
    address proxyAdminAddr;
    address counterV1Addr;
    address counterV2Addr;
    address impAddr;
    address impAddrM;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);

        vm.startPrank(alice);
        testSlot = new TestSlot();
        testSlotAddr = address(testSlot);
        console.log("testSlotAddr:", testSlotAddr);

        proxy = new Proxy();
        proxyAddr = address(proxy);
        console.log("proxyAddr:", proxyAddr);

        proxyAdmin = new ProxyAdmin();
        proxyAdminAddr = address(proxyAdmin);
        console.log("proxyAdminAddr:", proxyAdminAddr);

        counterV1 = new CounterV1();
        counterV1Addr = address(counterV1);
        console.log("counterV1Addr:", counterV1Addr);

        counterV2 = new CounterV2();
        counterV2Addr = address(counterV2);
        console.log("counterV2Addr:", counterV2Addr);
        vm.stopPrank();
    }

    function testATestSlot() public {
        console.log("---------== test TestSlot");
        addr1M = testSlot.getSlot();
        console.log("addr1M:", addr1M);
        assertEq(addr1M, zero);

        //get address located at this slot
        b32a = testSlot.slot();
        console.log("addr1");
        console.logBytes32(b32a); //0xa7cb26ea17989bb9c5eb391c94c40892dcdc94bb4c381353450910ba80883e1c

        testSlot.writeSlot(alice);
        addr1M = testSlot.getSlot();
        console.log("addr1M:", addr1M);
        assertEq(addr1M, alice);
    }

    function testProxy() public {
        console.log("---------== test Proxy");
        vm.startPrank(alice);
        adminM = proxy.admin();
        console.log("adminM:", adminM);
        assertEq(adminM, alice);

        impAddrM = proxy.implementation();
        console.log("impAddrM:", impAddrM);
        assertEq(impAddrM, zero);

        console.log("---------== Set impl to CounterV1");
        impAddr = counterV1Addr;
        proxy.upgradeTo(impAddr);
        impAddrM = proxy.implementation();
        assertEq(impAddrM, impAddr);
        vm.stopPrank();

        console.log("---------== Bob to test ifAdmin ... Separate user/admin interface");
        counterV1 = CounterV1(proxyAddr); //User V1
        //DO NOT BE CONFUSED WITH Proxy(proxyAddr), ERROR!!!
        vm.prank(bob);
        outAddr = counterV1.admin();
        console.log("CounterV1's admin:", outAddr);
        assertEq(outAddr, address(7));

        vm.prank(bob);
        outAddr = counterV1.implementation();
        console.log("CounterV1's implementation:", outAddr);
        assertEq(outAddr, address(8));

        console.log("---------== Alice to test ifAdmin");
        vm.prank(alice);
        outAddr = counterV1.admin();
        console.log("CounterV1's admin:", outAddr);
        assertEq(outAddr, alice);

        vm.prank(alice);
        outAddr = counterV1.implementation();
        console.log("CounterV1's implementation:", outAddr);
        assertEq(outAddr, impAddr);
    }

    function testZProxyAdmin() public {
        console.log("---------== test ProxyAdmin");
        vm.startPrank(alice);
        console.log("----== Set impl to CounterV1");
        impAddr = counterV1Addr;
        proxy.upgradeTo(impAddr);
        impAddrM = proxy.implementation();
        console.log("impAddrM:", impAddrM);
        assertEq(impAddrM, impAddr);

        console.log("----== Set proxy admin to proxyAdminAddr");
        proxy.changeAdmin(proxyAdminAddr);
        adminM = proxyAdmin.getProxyAdmin(proxyAddr);
        console.log("proxy's adminM:", adminM);
        assertEq(adminM, proxyAdminAddr);

        impAddrM = proxyAdmin.getProxyImplementation(proxyAddr);
        console.log("proxy's impAddrM:", impAddrM);
        assertEq(impAddrM, counterV1Addr);

        vm.stopPrank();
        console.log("----== Call CounterV1 with Proxy");
        count = 0;
        counterV1 = CounterV1(proxyAddr); //User V1
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count); //the same as the count at CounterV1

        console.log("to call inc()");
        counterV1.inc();
        counterV1.inc();
        count += 2;
        countM = counterV1.count();
        console.log("countM", countM);
        assertEq(countM, count);

        console.log("----==  Upgrade to CounterV2");
        impAddr = counterV2Addr;
        vm.startPrank(alice);
        proxyAdmin.upgrade(payable(proxyAddr), impAddr);
        impAddrM = proxyAdmin.getProxyImplementation(proxyAddr);
        console.log("proxy's impAddrM:", impAddrM);
        assertEq(impAddrM, impAddr);

        vm.stopPrank();
        counterV2 = CounterV2(proxyAddr); //User V2
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
