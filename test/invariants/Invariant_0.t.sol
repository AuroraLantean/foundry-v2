// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

// Topics
// - Invariant
// - Difference between fuzz and invariant
// - Failing invariant
// - Passing invariant
// - Stats - runs, calls, reverts

contract InvariantIntro {
    bool public flag; //should be always false

    function func_1() external {}
    function func_2() external {}
    function func_3() external {}
    function func_4() external {}

    function func_5() external {
        flag = true; //to fail invariant test below
    }
}

contract IntroInvariantTest is Test {
    InvariantIntro private target;

    function setUp() public {
        target = new InvariantIntro();
    }
    // Must start with "invariant"

    function invariant_flag_is_always_false() public {
        //will randomly call functions inside the target contract, then run assetEq() below to see if it passes the test. When func5 is called, the the test fails
        //assertEq(target.flag(), false);
    }
}
