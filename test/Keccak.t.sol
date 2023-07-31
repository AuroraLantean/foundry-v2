// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Keccak.sol";

contract KeccakTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 num;
    uint256 numM;
    uint256 inputValue = 13;
    uint256 etherValue;
    address payable addr1;
    address addr2;
    Keccak keccak;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        keccak = new Keccak();
        calleeAddr = address(keccak);
    }

    function test1() public {
        console.log("---------== test1");
        bytes memory b1 = keccak.encode("AAA", "BBB");
        console.logBytes(b1);

        bytes memory b1p = keccak.encodePacked("AAA", "BBB");
        console.logBytes(b1p);
        bytes memory b2p = keccak.encodePacked("AA", "ABBB");
        console.logBytes(b2p);
        assertEq(b1p, b2p);
        console.log("collision detected");

        bytes32 c1p = keccak.hashTxTx("AAA", "BBB");
        console.logBytes32(c1p);
        bytes32 c2p = keccak.hashTxTx("AA", "ABBB");
        console.logBytes32(c2p);
        assertEq(c1p, c2p);
        console.log("collision detected");

        bytes32 c1 = keccak.hashTxTx2("AAA", "BBB");
        console.logBytes32(c1);
        bytes32 c2 = keccak.hashTxTx2("AA", "ABBB");
        console.logBytes32(c2);
        if (c1 == c2) assertTrue(false); //assertNotEq(c1, c2);
        console.log("collision avoided");

        bytes32 c3a = keccak.hashTxUtTx("AAA", 1, "BBB");
        console.logBytes32(c3a);
        bytes32 c3b = keccak.hashTxUtTx("AA", 1, "ABBB");
        console.logBytes32(c3b);
        if (c3a == c3b) assertTrue(false); //assertNotEq(c1, c2);
        console.log("collision avoided");

        bool isCorrect = keccak.guess("Solidity");
        console.log("isCorrect:", isCorrect);
        assertTrue(isCorrect);
    }
}
