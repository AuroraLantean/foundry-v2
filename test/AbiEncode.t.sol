// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/AbiEncode.sol";

contract AbiEncodeTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address abiEncodeAddr;
    address tokenAddr;
    address addr1;
    address addr1M;
    address to;
    bytes data_encodeCell;
    bytes data_encodeWithSignature;
    bytes data_encodeWithSelector;
    uint256 num;
    uint256 timestamp;
    uint256 argX;
    uint256 argXM;
    uint256 ethSent;
    uint256 ethBalc;
    uint256 amount;
    string itemName;

    AbiEncode abiEncode;
    Token token;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        abiEncode = new AbiEncode();
        abiEncodeAddr = address(abiEncode);
        console.log("abiEncodeAddr:", abiEncodeAddr);

        token = new Token();
        tokenAddr = address(token);
        console.log("tokenAddr:", tokenAddr);
    }

    function test1() public {
        console.log("---------== test1");
        to = abiEncodeAddr;
        amount = 123;
        data_encodeWithSignature = abiEncode.encodeWithSignature(to, amount);
        console.log("data_encodeWithSignature:");
        console.logBytes(data_encodeWithSignature);

        data_encodeWithSelector = abiEncode.encodeWithSelector(to, amount);
        console.log("data_encodeWithSelector:");
        console.logBytes(data_encodeWithSelector);

        data_encodeCell = abiEncode.encodeCall(to, amount);
        console.log("data_encodeCell:");
        console.logBytes(data_encodeCell);

        assertEq(data_encodeWithSignature, data_encodeCell);
        assertEq(data_encodeWithSignature, data_encodeCell);

        abiEncode.callContractFunc(tokenAddr, data_encodeCell);
    }
}
