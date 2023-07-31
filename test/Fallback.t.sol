// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Fallback.sol";

contract FallbackTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNum = 100;
    FallbackIO fallbackIO;
    Dest dest;
    Departure departure;
    address fallbackIOAddr;
    address destAddr;
    address departureAddr;

    uint256 count;
    bytes b_get;
    bytes b_inc;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        dest = new Dest();
        destAddr = address(dest);

        fallbackIO = new FallbackIO(destAddr);
        fallbackIOAddr = address(fallbackIO);

        departure = new Departure();
        departureAddr = address(departure);
    }

    function test1() public {
        console.log("---------== test1");
        (b_get, b_inc) = departure.getCallData();
        count = departure.depart(fallbackIOAddr, b_get);
        console.log("get() count:", count);

        count = departure.depart(fallbackIOAddr, b_inc);
        console.log("inc() count:", count);

        count = departure.depart(fallbackIOAddr, b_get);
        console.log("get() count:", count);
    }
}
