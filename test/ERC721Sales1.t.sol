// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/ERC721Sales1.sol";

contract ERC20TokenTest is Test {
    address public tis = address(this);
    address public alice = address(1);
    address public bob = address(2);

    ERC20Token public erc20;
    ERC721Sales1 public sales;
    address public tokenAddr;
    address public salesAddr;
    address public ctrtOwner;

    receive() external payable {
        console.log("ETH received from:", msg.sender);
        console.log("ETH received in Szabo:", msg.value / 1e12);
    }

    function setUp() public {
        console.log("---------== Setup()");
        erc20 = new ERC20Token("Dragons", "DRG");
        tokenAddr = address(erc20);
        console.log("tokenAddr:", tokenAddr);
        ctrtOwner = erc20.owner();
        assertEq(ctrtOwner, tis);

        sales = new ERC721Sales1(tokenAddr);
        salesAddr = address(sales);
        console.log("salesAddr:", salesAddr);
    }

    function testInit() external {
        console.log("--------== testInit");
    }
}
