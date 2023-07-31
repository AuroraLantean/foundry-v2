// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Error.sol";

contract ErrorCtrtTest is Test {
    ErrCtrt public errCtrt;
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    uint256 time;
    uint256 executeTimeMin;
    bytes errdata;

    function setUp() public {
        errCtrt = new ErrCtrt();
    }

    function testFail() public view {
        errCtrt.throwError();
    }

    function testRevert() public {
        vm.expectRevert();
        errCtrt.throwError();
        errCtrt.succeed(); //secceed()
    }

    function testRequireMessage() public {
        //vm.expectRevert(bytes("not authorized"));
        vm.expectRevert("not authorized"); // text after 'Reason: '
        vm.prank(hacker);
        errCtrt.throwError();
    }

    function testCustomError() public {
        vm.expectRevert(ErrCtrt.NotAuthorized.selector);
        errCtrt.throwCustomError();
    }

    function testCustomErrorWithArg() public {
        time = 100 weeks;
        executeTimeMin = 135;
        vm.warp(time);
        errdata = abi.encodeWithSelector(ErrCtrt.TimeNotYetError.selector, time, executeTimeMin);
        console.logBytes(errdata);
        vm.expectRevert(errdata);
        errCtrt.throwCustomErrorWithArg();
    }

    // Add label to assertions
    function testErrorLabel() public {
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(1), "test 3");
        assertEq(uint256(1), uint256(1), "test 4");
        //assertEq(uint256(1), uint256(2), "test 4");
        assertEq(uint256(1), uint256(1), "test 5");
    }
}
