// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ForkTest is Test {
    IERC20 public dai;

    function setUp() public {
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    } //Dai Stablecoin deployed on Mainnet https://etherscan.io/token/0x6B175474E89094C44Da98b954EedeAC495271d0F

    function testDeposit() public {
        address alice = address(123);

        uint256 balBefore = dai.balanceOf(alice);
        console.log("DAI balance bf", balBefore);

        uint256 totalBefore = dai.totalSupply();
        console.log("DAI total supply bf", totalBefore / 1e18);

        // token, account, amount, adjust total supply
        deal(address(dai), alice, 1e6 * 1e18, true);

        uint256 balAfter = dai.balanceOf(alice);
        console.log("DAI balance af", balAfter / 1e18);

        uint256 totalAfter = dai.totalSupply();
        console.log("DAI total supply af", totalAfter / 1e18);
    }
}
