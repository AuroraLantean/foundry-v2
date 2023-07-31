// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/StakingRewardsD.sol";
import "src/ERC20Token.sol";

contract StakingRewardsDTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    uint256 tokAmt0;
    uint256 tokAmt0B4;
    uint256 tokAmt1;
    uint256 tokAmt1B4;
    address stakingRewardsDAddr;
    address token0Addr;
    address token1Addr;
    StakingRewardsDiscrete stakingRewardsD;
    ERC20Token token0;
    ERC20Token token1;
    address senderM;
    uint256 tokenAmount;
    uint256 tok0Approved;
    uint256 tok1Approved;
    uint256 tokBalcAlice;
    uint256 tokBalcAliceB4;
    uint256 tokIncrease;
    uint256 tokProfit;
    uint256 shareBalc;
    uint256 shareBalcB4;
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

    uint256 rwTokAmtSent;
    uint256 rwTokenAmt;
    uint256 reTokBalc;
    uint256 totalStaked;
    uint256 totalStakedM;
    uint256 stakingAmt;
    uint256 unstakingAmt;
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

        stakingRewardsD = new StakingRewardsDiscrete(token0Addr, token1Addr);
        stakingRewardsDAddr = address(stakingRewardsD);
        tok0Approved = tokenAmount;
        tok1Approved = tokenAmount;
        token0.approve(stakingRewardsDAddr, tok0Approved);
        token1.approve(stakingRewardsDAddr, tok1Approved);

        rwTokAmtSent = tokenAmount;
        token1.transfer(stakingRewardsDAddr, rwTokAmtSent);
        reTokBalc = token1.balanceOf(stakingRewardsDAddr);
        assertEq(reTokBalc, rwTokAmtSent);

        vm.startPrank(bob);
        token0.approve(stakingRewardsDAddr, tok0Approved);
        //token1.approve(stakingRewardsDAddr, tok1Approved);
        vm.stopPrank();
    }

    function test1() public {
        stakingAmt = 100;
        console.log("-------== Bob stakes", stakingAmt, "tokens");
        vm.prank(bob);
        stakingRewardsD.stake(stakingAmt);
        tok0StakedBobM = stakingRewardsD.staked(bob);
        console.log("stakingAmt:", stakingAmt, ", tok0StakedBobM:", tok0StakedBobM);
        assertEq(tok0StakedBobM, stakingAmt);
        tok0StakedBobMB4 = tok0StakedBobM;

        totalStaked += stakingAmt;
        totalStakedM = stakingRewardsD.totalStaked();
        console.log("totalStakedM:", totalStakedM, totalStakedM / 1e18);
        assertEq(totalStakedM, totalStaked);

        rwTokenAmt = 1000;
        console.log("-------== Alice deposit", rwTokenAmt, "reward tokens");
        vm.prank(alice);
        stakingRewardsD.depositReward(rwTokenAmt);

        //vm.prank(bob);
        earnedReward = stakingRewardsD.calculateRewardsEarned(bob);
        console.log("Bob earnedReward:", earnedReward);

        console.log("-------== claimReward()");
        tok1BalcBobB4 = token1.balanceOf(bob);
        vm.prank(bob);
        stakingRewardsD.claim();
        tok1BalcBob = token1.balanceOf(bob);
        tok1IcrBob = tok1BalcBob - tok1BalcBobB4;
        console.log("tok1IcrBob:", tok1IcrBob, tok1IcrBob / 1e18);
        assertEq(tok1IcrBob, earnedReward);

        earnedReward = stakingRewardsD.calculateRewardsEarned(bob);
        console.log("Bob earnedReward:", earnedReward);
        assertEq(earnedReward, 0);

        unstakingAmt = 100;
        console.log("-------== Bob unstakes", unstakingAmt, "tokens");
        vm.prank(bob);
        stakingRewardsD.unstake(unstakingAmt);
        tok0StakedBobM = stakingRewardsD.staked(bob);
        console.log("unstakingAmt:", unstakingAmt, ", tok0StakedBobM:", tok0StakedBobM);
        assertEq(tok0StakedBobM, tok0StakedBobMB4 - unstakingAmt);
        tok0StakedBobMB4 = tok0StakedBobM;

        totalStaked -= unstakingAmt;
        totalStakedM = stakingRewardsD.totalStaked();
        console.log("totalStakedM:", totalStakedM, totalStakedM / 1e18);
        assertEq(totalStakedM, totalStaked);
    }
}
