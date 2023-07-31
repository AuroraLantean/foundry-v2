// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/AbiDecode.sol";

contract AbiDecodeTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address multiDelegatecallAddr;
    address abiDecodeAddr;
    address addr1;
    address addr1M;
    bytes encodedData;
    bytes calldata2;
    bytes calldataMint;
    uint256 num;
    uint256 timestamp;
    uint256 argX;
    uint256 argXM;
    uint256 ethSent;
    uint256 ethBalc;
    address[] targets;
    bytes[] calldatas;
    bytes[] results;
    uint256[2] itemNums;
    uint256[] nums;
    uint256[] numsM;
    AbiDecode.Item item;
    AbiDecode.Item itemM;
    string itemName;

    AbiDecode abiDecode;
    Helper helper;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        abiDecode = new AbiDecode();
        abiDecodeAddr = address(abiDecode);
        console.log("abiDecodeAddr:", abiDecodeAddr);
    }

    function test1() public {
        console.log("---------== test1");
        argX = 7;
        addr1 = address(13);
        itemNums = [11, 12];
        itemName = "john";
        item = AbiDecode.Item(itemName, itemNums);
        nums.push(101);
        nums.push(102);
        nums.push(103);

        encodedData = abiDecode.encode(argX, addr1, nums, item);
        console.log("encodedData:");
        console.logBytes(encodedData);

        (argXM, addr1M, numsM, itemM) = abiDecode.decode(encodedData);
        console.log("argXM:", argXM, ", addr1M:", addr1M);
        console.log("nums[0]:", nums[0], ", nums[1]:", nums[1]);
        console.log("itemM:", itemM.name, itemM.nums[0], itemM.nums[1]);
        assertEq(argX, argXM);
        assertEq(addr1, addr1M);
        assertEq(nums[0], numsM[0]);
        assertEq(nums[1], numsM[1]);
        assertEq(nums[2], numsM[2]);
        assertEq(itemName, itemM.name);
        assertEq(itemNums[0], itemM.nums[0]);
        assertEq(itemNums[1], itemM.nums[1]);
    }
}
