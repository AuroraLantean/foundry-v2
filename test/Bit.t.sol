// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Bit.sol";
//import "src/ERC20Token.sol";

contract BitTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);

    Bit bit;
    address bitAddr;
    address addr1;
    address addr1M;
    uint32 time1;
    uint32 time1M;
    uint32 time2;
    uint32 time2M;
    uint16 num16;
    uint16 num16M;
    uint8 index;
    uint8 num8;
    uint8 num8M;
    bool bool1;
    bool bool1M;
    bool boolx;
    bool boolxM;
    uint256 out;
    uint256 outExpected;

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        bit = new Bit();
        bitAddr = address(bit);
        console.log("bitAddr:", bitAddr);
    }

    function test1() public {
        console.log("------------== test1");
        console.log("----== set & read addr1");
        addr1M = bit.getAddr();
        console.log("addr1M:", addr1M);

        addr1 = address(uint160(type(uint128).max));
        bit.setAddr(addr1);
        addr1M = bit.getAddr();
        console.log("addr1M:", addr1M);
        assertEq(addr1M, addr1);

        console.log("----== set & read time1");
        time1M = bit.getTime1();
        console.log("time1M:", time1M);

        time1 = uint32(4294967295); // max time
        bit.setTime1(time1);
        time1M = bit.getTime1();
        console.log("time1M:", time1M);
        assertEq(time1M, time1);

        console.log("----== set & read time2");
        time2M = bit.getTime2();
        console.log("time2M:", time2M);

        time2 = uint32(1720000002);
        bit.setTime2(time2);
        time2M = bit.getTime2();
        console.log("time2M:", time2M);
        assertEq(time2M, time2);

        console.log("----== set & read num16");
        num16M = bit.getNum16();
        console.log("num16M:", num16M);

        num16 = uint16(65535); //max value
        bit.setNum16(num16);
        num16M = bit.getNum16();
        console.log("num16M:", num16M);
        assertEq(num16M, num16);

        console.log("----== set & read num8");
        num8M = bit.getNum8();
        console.log("num8M:", num8M);

        num8 = uint8(255); //max value
        bit.setNum8(num8);
        num8M = bit.getNum8();
        console.log("num8M:", num8M);
        assertEq(num8M, num8);

        index = 248;
        boolx = false;
        console.log("----== set & read bool at index =", index);
        boolxM = bit.getBoolx(index);
        console.log("boolxM:", boolxM);

        boolx = true;
        bit.setBoolx(boolx, index);
        boolxM = bit.getBoolx(index);
        console.log("boolxM:", boolxM);
        assertEq(boolxM, boolx);

        index = 255;
        boolx = false;
        console.log("----== set & read bool at index =", index);
        boolxM = bit.getBoolx(index);
        console.log("boolxM:", boolxM);

        boolx = true;
        bit.setBoolx(boolx, index);
        boolxM = bit.getBoolx(index);
        console.log("boolxM:", boolxM);
        assertEq(boolxM, boolx);

        boolx = false;
        bit.setBoolx(boolx, index);
        boolxM = bit.getBoolx(index);
        console.log("boolxM:", boolxM);
        assertEq(boolxM, boolx);

        //--------------==
        console.log("----== Check if previous set data unchanged");
        addr1M = bit.getAddr();
        console.log("addr1M:", addr1M);
        assertEq(addr1M, addr1);

        time1M = bit.getTime1();
        console.log("time1M:", time1M);
        assertEq(time1M, time1);

        time2M = bit.getTime2();
        console.log("time2M:", time2M);
        assertEq(time2M, time2);

        num16M = bit.getNum16();
        console.log("num16M:", num16M);
        assertEq(num16M, num16);

        num8M = bit.getNum8();
        console.log("num8M:", num8M);
        assertEq(num8M, num8);

        index = 248;
        bool1 = true;
        bool1M = bit.getBoolx(index);
        console.log("bool1M:", bool1M);
        assertEq(bool1M, bool1);
    }
}
