// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/BitwiseOperators.sol";
//import "src/ERC20Token.sol";

contract BitwiseOperatorsTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    address bitwiseOpsAddr;
    BitwiseOps bitwiseOps;
    uint256 x;
    uint256 y;
    uint256 out;
    uint256 outExpected;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        bitwiseOps = new BitwiseOps();
        bitwiseOpsAddr = address(bitwiseOps);
        console.log("bitwiseOpsAddr:", bitwiseOpsAddr);
    }

    function test1() public {
        console.log("-------== and()");
        x = 14;
        y = 11;
        outExpected = 10;
        out = bitwiseOps.and(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== or()");
        x = 12;
        y = 9;
        outExpected = 13;
        out = bitwiseOps.or(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== xor()");
        x = 12;
        y = 5;
        outExpected = 9;
        out = bitwiseOps.xor(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== not()");
        x = 12;
        outExpected = 243;
        out = bitwiseOps.not(uint8(x));
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== shiftLeft()");
        x = 3;
        y = 2;
        outExpected = 12;
        out = bitwiseOps.shiftLeft(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== shiftRight()");
        x = 12;
        y = 1;
        outExpected = 6;
        out = bitwiseOps.shiftRight(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== getLastNBits()");
        x = 13;
        y = 3;
        outExpected = 5;
        out = bitwiseOps.getLastNBits(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== getLastNBitsUsingMod()");
        x = 13;
        y = 3;
        outExpected = 5;
        out = bitwiseOps.getLastNBitsUsingMod(x, y);
        console.log("x:", x, ", y:", y);
        console.log("out:", out);
        assertEq(out, outExpected);

        console.log("-------== mostSignificantBitViaShiftRight()");
        x = 10;
        outExpected = 3;
        out = bitwiseOps.mostSignificantBitViaShiftRight(x);
        console.log("x:", x, ", out:", out);
        assertEq(out, outExpected);

        console.log("-------== mostSigBitViaBinarySearch()");
        x = 8;
        outExpected = 3;
        out = bitwiseOps.mostSigBitViaBinarySearch(x);
        console.log("x:", x, ", out:", out);
        assertEq(out, outExpected);

        x = 9;
        outExpected = 3; //1001
        out = bitwiseOps.mostSigBitViaBinarySearch(x);
        console.log("x:", x, ", out:", out);
        assertEq(out, outExpected);

        x = 15;
        outExpected = 3; //1111
        out = bitwiseOps.mostSigBitViaBinarySearch(x);
        console.log("x:", x, ", out:", out);
        assertEq(out, outExpected);

        x = 16;
        outExpected = 4; //10000
        out = bitwiseOps.mostSigBitViaBinarySearch(x);
        console.log("x:", x, ", out:", out);
        assertEq(out, outExpected);

        // console.log("-------== mostSigBitViaAssembly()");
        // x = 14; y = 11;
        // out = bitwiseOps.mostSigBitViaAssembly(x);
        // console.log("x:", x, ", y:", y);
        // console.log("out:", out);
        // assertEq(out, 10);
    }
}
