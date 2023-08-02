// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import "src/ERC721Token.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new ERC721Token("Dragons", "DRG");
    }
}
