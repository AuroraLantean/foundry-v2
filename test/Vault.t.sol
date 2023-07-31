// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Vault.sol";
import "src/ERC20Token.sol";

contract VaultTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNumProxy = 5;
    uint256 inputNum = 100;
    uint256 inputValue = 13;
    uint256 tokAmt;
    address vaultAddr;
    address erc20Addr;
    address addr2;
    Vault vault;
    ERC20Token erc20;
    address senderM;
    uint256 tokBalcAlice;
    uint256 tokBalcAliceB4;
    uint256 tokApproved;
    uint256 tokIncrease;
    uint256 tokBalcVault;
    uint256 tokProfit;
    uint256 shareBalc;
    uint256 shareBalcB4;
    uint256 vaultBalc;
    uint256 totalShares;
    uint256 totalSharesB4;
    uint256 shareWithdrawn;
    uint256 shareModifier;
    uint256 tokOutExpected;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        vm.startPrank(alice);
        erc20 = new ERC20Token("GoldCoin", "GLDC");
        erc20Addr = address(erc20);
        console.log("erc20Addr:", erc20Addr);

        vault = new Vault(erc20Addr);
        vaultAddr = address(vault);
        tokApproved = 1000;
        erc20.approve(vaultAddr, tokApproved);
        vm.stopPrank();
    }

    function test1() public {
        console.log("---------== test1");
        tokAmt = 1000;
        vm.prank(alice);
        vault.deposit(tokAmt);
        shareBalc = vault.userShares(alice);
        console.log("tokAmt: ", tokAmt, ", shareBalc: ", shareBalc);
        assertEq(shareBalc, tokAmt);
        shareBalcB4 = tokAmt;

        totalShares = vault.totalShares();
        console.log("totalShares: ", totalShares);
        assertEq(totalShares, shareBalc);
        totalSharesB4 = totalShares;

        console.log("---------== Scenario 1: token balance increases from external DeFi investment profit");
        vm.prank(alice);
        tokProfit = 2000;
        console.log("tokProfit: ", tokProfit);
        erc20.transfer(vaultAddr, tokProfit); //simulating profit
        tokBalcVault = erc20.balanceOf(vaultAddr);
        console.log("tokBalcVault: ", tokBalcVault);
        assertEq(tokBalcVault, tokProfit + tokAmt);

        shareModifier = (tokProfit + tokAmt) * 100 / tokAmt;
        console.log("shareModifier: ", shareModifier);

        shareWithdrawn = shareBalc;
        tokBalcAlice = erc20.balanceOf(alice);
        console.log("tokBalcAlice: ", tokBalcAlice);
        console.log("shareWithdrawn: ", shareWithdrawn);
        tokBalcAliceB4 = tokBalcAlice;

        vm.prank(alice);
        vault.withdraw(shareWithdrawn);

        shareBalc = vault.userShares(alice);
        console.log("shareBalc: ", shareBalc);
        assertEq(shareBalc, shareBalcB4 - shareWithdrawn);
        totalShares = vault.totalShares();
        console.log("totalShares: ", totalShares);
        assertEq(totalShares, totalSharesB4 - shareWithdrawn);

        tokBalcAlice = erc20.balanceOf(alice);
        tokIncrease = tokBalcAlice - tokBalcAliceB4;
        console.log("tokBalcAlice: ", tokBalcAlice, ", token increase:", tokIncrease);

        tokOutExpected = shareWithdrawn * shareModifier / 100;
        console.log("tokOutExpected: ", tokOutExpected);
        assertEq(tokIncrease, tokOutExpected);
    }
}
