// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
//ERROR, Unknown DAI behavior...

contract ForkTest is Test {
    IERC20 public dai;
    uint256 amount;

    function setUp() public {
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    } //Dai Stablecoin deployed on Mainnet https://etherscan.io/token/0x6B175474E89094C44Da98b954EedeAC495271d0F

    function testDeposit() public {
        address alice = address(1);

        uint256 balBf = dai.balanceOf(alice);
        console.log("DAI balance bf:", balBf / 1e18, balBf);

        uint256 totalSupplyBf = dai.totalSupply();
        console.log("DAI totalSupplyBf:", totalSupplyBf / 1e18, totalSupplyBf);

        amount = 1000;
        // token, account, amount, adjust total supply
        deal(address(dai), alice, amount, true);

        uint256 balAf = dai.balanceOf(alice);
        console.log("DAI balance af:", balAf / 1e18, balAf);
        assertEq(balAf, balBf + amount, "err1");
        //   5597 963978833455292775
        //1000000 000000000000000000
        //1005597 963978833455292775

        uint256 totalSupplyAf = dai.totalSupply();
        console.log("DAI totalSupplyAf:", totalSupplyAf / 1e18, totalSupplyAf);
        assertEq(balAf, balBf + amount, "err2");
    }
}
