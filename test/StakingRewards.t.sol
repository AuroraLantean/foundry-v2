// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/StakingRewards.sol";
import "src/ERC20Token.sol";

contract StakingRewardsTest is Test {
    address public zero = address(0);
    address public alice = address(1);
    address public bob = address(2);
    address public charlie = address(3);
    uint256 public tokAmt0;
    uint256 public tokAmt0B4;
    uint256 public tokAmt1;
    uint256 public tokAmt1B4;
    address public stakingRewardsAddr;
    address public token0Addr;
    address public token1Addr;
    StakingRewards public stakingRewards;
    ERC20Token public token0;
    ERC20Token public token1;
    address public senderM;
    uint256 public tokenAmount;
    uint256 public tok0Approved;
    uint256 public tok1Approved;
    uint256 public tokBalcAlice;
    uint256 public tokBalcAliceB4;
    uint256 public tokIncrease;
    uint256 public tokBalcConstProductAMM;
    uint256 public tokProfit;
    uint256 public shareBalc;
    uint256 public shareBalcB4;
    uint256 public addedShares;
    uint256 public totalShares;
    uint256 public tok0BalcAliceB4;
    uint256 public tok1BalcAliceB4;
    uint256 public tok0IcrAlice;
    uint256 public tok1DcrAlice;
    uint256 public tok1BalcBob;
    uint256 public tok1BalcBobB4;
    uint256 public tok0DcrBob;
    uint256 public tok1IcrBob;
    uint256 public tok0BalcAlice;
    uint256 public tok1BalcAlice;
    uint256 public totalSharesB4;
    uint256 public removedShares;
    uint256 public shareWithdrawn;
    uint256 public shareModifier;
    uint256 public tokOutExpected;
    uint256 public swapAmtIn;
    uint256 public swapAmtOut;
    uint256 public res0BalcDiff;
    uint256 public res1BalcDiff;

    uint256 public deploymentTime;
    uint256 public rewardDuration;
    uint256 public rewardDurationM;
    uint256 public rwTokAmtSent;
    uint256 public reTokBalc;
    uint256 public rewardRate;
    uint256 public rewardRateM;
    uint256 public stakingAmt;
    uint256 public tok0StakedBobM;
    uint256 public earnedReward;
    uint256 public earnedRewardM;
    uint256 public tok0StakedBobMB4;
    uint256 public stakingWithdrawnAmt;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);
        deploymentTime = 2800 weeks;
        vm.warp(deploymentTime);
        tokenAmount = 1000 ether;

        vm.startPrank(alice);
        token0 = new ERC20Token("StakedToken", "TOK0");
        token0Addr = address(token0);
        console.log("token0Addr:", token0Addr);
        token0.mint(bob, tokenAmount);
        tok0BalcAliceB4 = token0.balanceOf(alice);

        token1 = new ERC20Token("RewardToken", "TOK1");
        token1Addr = address(token1);
        console.log("token1Addr:", token1Addr);
        token1.mint(bob, tokenAmount);
        tok1BalcAliceB4 = token1.balanceOf(alice);

        stakingRewards = new StakingRewards(token0Addr, token1Addr);
        stakingRewardsAddr = address(stakingRewards);
        tok0Approved = tokenAmount;
        tok1Approved = tokenAmount;
        //token0.approve(stakingRewardsAddr, tok0Approved);
        //token1.approve(stakingRewardsAddr, tok1Approved);

        rwTokAmtSent = tokenAmount;
        rewardDuration = 1000;
        token1.transfer(stakingRewardsAddr, rwTokAmtSent);
        reTokBalc = token1.balanceOf(stakingRewardsAddr);
        assertEq(reTokBalc, rwTokAmtSent);

        stakingRewards.setRewardsDuration(rewardDuration);
        rewardDurationM = stakingRewards.duration();
        console.log("rewardDuration:", rewardDuration, ", rewardDurationM:", rewardDurationM);
        assertEq(rewardDurationM, rewardDuration);

        stakingRewards.setRewardRateAndFinishedAt(rwTokAmtSent);
        rewardRateM = stakingRewards.rewardRate();
        rewardRate = rwTokAmtSent / rewardDuration;

        console.log("rewardRate:", rewardRate, ", rewardRateM:", rewardRateM);
        console.log("rewardRate:", rewardRate / 1e18, ", rewardRateM:", rewardRateM / 1e18);
        assertEq(rewardRateM, rewardRate);
        vm.stopPrank();

        vm.startPrank(bob);
        token0.approve(stakingRewardsAddr, tok0Approved);
        //token1.approve(stakingRewardsAddr, tok1Approved);
        vm.stopPrank();
    }

    function test1() public {
        console.log("-------== stake()");
        stakingAmt = tokenAmount;
        vm.prank(bob);
        stakingRewards.stake(stakingAmt);
        tok0StakedBobM = stakingRewards.staked(bob);
        console.log("stakingAmt:", stakingAmt, ", tok0StakedBobM:", tok0StakedBobM);
        assertEq(tok0StakedBobM, stakingAmt);
        tok0StakedBobMB4 = tok0StakedBobM;

        earnedReward = stakingRewards.getEarned(bob);
        console.log("earnedReward:", earnedReward, earnedReward / 1e18);
        console.log("warp to rewardDuration end");
        vm.warp(deploymentTime + rewardDuration);
        earnedReward = stakingRewards.getEarned(bob);
        console.log("earnedReward:", earnedReward, earnedReward / 1e18);
        assertEq(earnedReward, rewardRate * rewardDuration);

        console.log("-------== claimReward()");
        tok1BalcBobB4 = token1.balanceOf(bob);
        vm.prank(bob);
        stakingRewards.claimReward();
        tok1BalcBob = token1.balanceOf(bob);
        tok1IcrBob = tok1BalcBob - tok1BalcBobB4;
        console.log("tok1IcrBob:", tok1IcrBob, tok1IcrBob / 1e18);
        assertEq(tok1IcrBob, earnedReward);

        console.log("-------== withdraw()");
        tok0StakedBobM = stakingRewards.staked(bob);
        console.log("tok0StakedBobM:", tok0StakedBobM, tok0StakedBobM / 1e18);
        assertEq(tok0StakedBobM, tok0StakedBobMB4);

        stakingWithdrawnAmt = tok0StakedBobM;
        vm.prank(bob);
        stakingRewards.withdraw(stakingWithdrawnAmt);

        tok0StakedBobM = stakingRewards.staked(bob);
        console.log("tok0StakedBobM:", tok0StakedBobM, tok0StakedBobM / 1e18);
        assertEq(tok0StakedBobM, tok0StakedBobMB4 - stakingWithdrawnAmt);
    }
}
