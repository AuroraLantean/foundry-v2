// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/StakingRewards.sol";
import "src/ERC20Token.sol";

contract StakingRewardsTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    uint256 tokAmt0;
    uint256 tokAmt0B4;
    uint256 tokAmt1;
    uint256 tokAmt1B4;
    address stakingRewardsAddr;
    address token0Addr;
    address token1Addr;
    StakingRewards stakingRewards;
    ERC20Token token0;
    ERC20Token token1;
    address senderM;
    uint256 tokenAmount;
    uint256 tok0Approved;
    uint256 tok1Approved;
    uint256 tokBalcAlice;
    uint256 tokBalcAliceB4;
    uint256 tokIncrease;
    uint256 tokBalcConstProductAMM;
    uint256 tokProfit;
    uint256 shareBalc;
    uint256 shareBalcB4;
    uint256 addedShares;
    uint256 totalShares;
    uint256 tok0BalcAliceB4;
    uint256 tok1BalcAliceB4;
    uint256 tok0IcrAlice;
    uint256 tok1DcrAlice;
    uint256 tok1BalcBob;
    uint256 tok1BalcBobB4;
    uint256 tok0DcrBob;
    uint256 tok1IcrBob;
    uint256 tok0BalcAlice;
    uint256 tok1BalcAlice;
    uint256 totalSharesB4;
    uint256 removedShares;
    uint256 shareWithdrawn;
    uint256 shareModifier;
    uint256 tokOutExpected;
    uint256 swapAmtIn;
    uint256 swapAmtOut;
    uint256 res0BalcDiff;
    uint256 res1BalcDiff;

    uint256 deploymentTime;
    uint256 rewardDuration;
    uint256 rewardDurationM;
    uint256 rwTokAmtSent;
    uint256 reTokBalc;
    uint256 rewardRate;
    uint256 rewardRateM;
    uint256 stakingAmt;
    uint256 tok0StakedBobM;
    uint256 earnedReward;
    uint256 earnedRewardM;
    uint256 tok0StakedBobMB4;
    uint256 stakingWithdrawnAmt;

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
