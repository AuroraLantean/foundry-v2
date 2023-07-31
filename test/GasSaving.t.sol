// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/GasSaving.sol";

contract GasSavingTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address gasSavingAddr;
    address addr1;
    address addr1M;
    bytes encodedData;
    bytes calldata2;
    bytes calldataMint;
    uint256 num;
    uint256 total;
    uint256 argX;
    uint256 argXM;
    uint256 ethSent;
    uint256 ethBalc;
    address[] targets;
    bytes[] calldatas;
    bytes[] results;
    uint256[2] itemNums;
    uint256[] nums = [1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 100];
    uint256[] numsM;
    string itemName;

    GasSaving gasSaving;

    event Log(address indexed caller, string indexed func, uint256 i);

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        gasSaving = new GasSaving();
        gasSavingAddr = address(gasSaving);
        console.log("gasSavingAddr:", gasSavingAddr);
    }

    function test1() public {
        console.log("---------== test1"); //gas: 87597
        gasSaving.sumEvenAndLessThan99MoreGas(nums);
        total = gasSaving.total();
        console.log("total:", total);
    }

    function test2() public {
        console.log("---------== test2"); //gas: 83644
        gasSaving.sumEvenAndLessThan99(nums);
        total = gasSaving.total();
        console.log("total:", total);
    }
}
