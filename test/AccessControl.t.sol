// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/AccessControl.sol";

contract AccessControlTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 num;
    uint256 numM;
    uint256 inputValue = 13;
    uint256 etherValue;
    address payable addr1;
    address addr2;
    AccessControl callee;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;
    bool isTrue;

    //Change ADMIN and USER to public to get the following data in AccessControl.sol, then change them back to save gas
    bytes32 admin = 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42;
    bytes32 user = 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        vm.prank(alice);
        callee = new AccessControl();
        calleeAddr = address(callee);
    }

    function test1() public {
        console.log("---------== test1");
        /*bytes32 b1 = callee.ADMIN();
        console.logBytes32(b1);

        bytes32 b2 = callee.USER();
        console.logBytes32(b2);
        */

        isTrue = callee.roles(admin, alice);
        console.log("isTrue: ", isTrue);
        assertEq(isTrue, true);

        //---------== grant Bob the role of user
        isTrue = callee.roles(user, bob);
        console.log("isTrue: ", isTrue);
        assertEq(isTrue, false);

        vm.prank(alice);
        callee.grantRole(user, bob);
        isTrue = callee.roles(user, bob);
        console.log("isTrue: ", isTrue);
        assertEq(isTrue, true);

        //---------== revoke Bob the role of user
        vm.prank(alice);
        callee.revokeRole(user, bob);
        isTrue = callee.roles(user, bob);
        console.log("isTrue: ", isTrue);
        assertEq(isTrue, false);
    }
}
