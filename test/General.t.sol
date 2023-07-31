// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/General.sol";

contract GeneralTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNum = 100;
    General gen;
    address payable addr1;
    //uint[] public arr;
    //General.Item[] public items;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        gen = new General(alice);
    }

    function testArray1() public {
        console.log("---------== testArray1");
        //console.log("array:", gen.array());
        assertEq(gen.getLength(), 6);
        uint256 removed = gen.removeWithOrder(2);
        console.log("removed:", removed);
        // [1, 2, 4, 5]
        assertEq(gen.arr(0), 1);
        assertEq(gen.arr(1), 2);
        assertEq(gen.arr(2), 4);
        assertEq(gen.arr(3), 5);
        assertEq(gen.arr(4), 6);
        assertEq(gen.getLength(), 5);

        removed = gen.removeWithOrder(4);
        console.log("removed:", removed);
        removed = gen.removeWithOrder(3);
        console.log("removed:", removed);
        removed = gen.removeWithOrder(2);
        console.log("removed:", removed);
        removed = gen.removeWithOrder(1);
        console.log("removed:", removed);
        removed = gen.removeWithOrder(0);
        console.log("removed:", removed);
        assertEq(gen.getLength(), 0);
    }

    function testArray2() public {
        console.log("---------== testArray2");
        assertEq(gen.getLength(), 6);
        uint256 removed = gen.removeSwap(1);
        console.log("removed:", removed);
        // [1, 6, 3, 4, 5]
        assertEq(gen.arr(0), 1);
        assertEq(gen.arr(1), 6);
        assertEq(gen.arr(2), 3);
        assertEq(gen.arr(3), 4);
        assertEq(gen.arr(4), 5);
        assertEq(gen.getLength(), 5);

        removed = gen.removeSwap(4);
        console.log("removed:", removed);
        removed = gen.removeSwap(3);
        console.log("removed:", removed);
        removed = gen.removeSwap(2);
        console.log("removed:", removed);
        removed = gen.removeSwap(1);
        console.log("removed:", removed);
        removed = gen.removeSwap(0);
        console.log("removed:", removed);
        assertEq(gen.getLength(), 0);
    }

    function testArrayStructMapping() public {
        console.log("---------== testArrayStructMapping");
        uint256 size = gen.getMapItemSize(alice);
        assertEq(size, 0);

        vm.prank(alice);
        gen.addMapItem(101);
        size = gen.getMapItemSize(alice);
        assertEq(size, 1);

        General.Item memory item = gen.getMapItem(alice, 0);
        console.log("item0:", item.num, item.ctrt);
        assertEq(item.num, 101);
        assertEq(item.ctrt, zero);

        (uint256 num, address ctrt) = gen.itemsByOwner(alice, 0);
        console.log("item0:", num, ctrt);

        vm.prank(alice);
        gen.addMapItem(102);
        size = gen.getMapItemSize(alice);
        assertEq(size, 2);

        item = gen.getMapItem(alice, 1);
        console.log("item1:", item.num, item.ctrt);
        assertEq(item.num, 102);
        assertEq(item.ctrt, zero);

        vm.prank(alice);
        gen.updateMapItem(1, 112);
        item = gen.getMapItem(alice, 1);
        console.log("item1:", item.num, item.ctrt);
        assertEq(item.num, 112);
        assertEq(item.ctrt, zero);
    }
}
