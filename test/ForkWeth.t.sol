// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IWETH_dup {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

contract ForkWethTest is Test {
    IWETH_dup public weth;
    uint256 amount;

    function setUp() public {
        weth = IWETH_dup(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //deployed on Mainnet https://etherscan.io/token/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    }

    function testDeposit() public {
        uint256 balBf = weth.balanceOf(address(this));
        console.log("balance before:", balBf);

        amount = 1000;
        weth.deposit{value: amount}(); //value in wei

        uint256 balAf = weth.balanceOf(address(this));
        console.log("balance after:", balAf);
        assertEq(balAf, balBf + amount);
    }
}
