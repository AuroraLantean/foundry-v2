// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/CrowdFund.sol";
import "src/ERC20Token.sol";

contract CrowdfundTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address chaz = address(3);
    address dave = address(4);
    address maker;
    address makerM;
    uint256 campaignId;
    uint256 pledgeAmt1;
    uint256 pledgeAmtUserTotal;
    uint256 pledgeAmtUserTotalM;
    uint256 num;
    uint256 tokenAmt;
    uint256 numM;
    uint32 campaignDuration;
    uint32 time;
    uint32 timeM;
    uint32 startAt;
    uint32 startAtM;
    uint32 endAt;
    uint32 endAtM;
    uint256 pledged;
    uint256 pledgedM;
    uint256 goal;
    uint256 goalM;
    bool claimed;
    bool claimedM;
    uint256 etherValue;
    address addrAppvd;
    CrowdFund crowdfund;
    ERC20Token erc20;
    address erc20Addr;
    address crowdfundAddr;
    address senderM;
    uint256 ethBalc;
    uint256 tokBalc1;
    uint256 tokBalc;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        deal(chaz, 1000 ether);
        deal(dave, 1000 ether);

        vm.startPrank(alice);
        erc20 = new ERC20Token("GoldCoin", "GLDC");
        erc20Addr = address(erc20);
        console.log("erc20Addr:", erc20Addr);
        tokenAmt = 1000; //7 * 10 ** 21
        erc20.mint(bob, tokenAmt);
        erc20.mint(chaz, tokenAmt);
        erc20.mint(dave, tokenAmt);

        crowdfund = new CrowdFund(erc20Addr);
        crowdfundAddr = address(crowdfund);
        console.log("crowdfundAddr:", crowdfundAddr);
        erc20.approve(crowdfundAddr, tokenAmt);
        vm.stopPrank();

        vm.prank(bob);
        erc20.approve(crowdfundAddr, tokenAmt);
        vm.prank(chaz);
        erc20.approve(crowdfundAddr, tokenAmt);
        vm.prank(dave);
        erc20.approve(crowdfundAddr, tokenAmt);

        time = 1689392786; //in JS: new Date().getTime()/1000
        vm.warp(time);
        timeM = crowdfund.getTime();
        console.log("time: ", time);
        assertEq(time, timeM);
    }

    function testSuccessCampaign() public {
        console.log("---------== testSuccessCampaign");
        startAt = time;
        endAt = time + campaignDuration;
        goal = 250;
        vm.prank(alice);
        crowdfund.launch(goal, startAt, endAt);

        campaignId = 1;
        (makerM, goalM, pledgedM, startAtM, endAtM, claimedM) = crowdfund.campaigns(campaignId);
        console.log("Campaign campaignId:", campaignId, ", maker:", makerM);
        console.log("goal:", goalM, ", pledged:", pledgedM);
        console.log("startAt:", startAtM, ", endAt:", endAtM);
        assertEq(alice, makerM);
        assertEq(goal, goalM);
        assertEq(pledged, pledgedM);
        assertEq(startAt, startAtM);
        assertEq(endAt, endAtM);
        assertEq(claimed, false);

        //--------------==
        pledgeAmt1 = 100;
        pledged += pledgeAmt1;
        vm.prank(bob);
        crowdfund.pledge(campaignId, pledgeAmt1);
        (, goalM, pledgedM,,,) = crowdfund.campaigns(campaignId);
        console.log("goal:", goalM, ", pledged:", pledgedM);
        assertEq(pledged, pledgedM);

        pledgeAmtUserTotal = 100;
        pledgeAmtUserTotalM = crowdfund.pledgedAmount(campaignId, bob);
        console.log("pledgeAmtUserTotal:", pledgeAmtUserTotalM);
        assertEq(pledgeAmtUserTotal, pledgeAmtUserTotalM);

        //--------------==
        pledgeAmt1 = 150;
        pledged += pledgeAmt1;
        vm.prank(chaz);
        crowdfund.pledge(campaignId, pledgeAmt1);
        (, goalM, pledgedM,,,) = crowdfund.campaigns(campaignId);
        console.log("goal:", goalM, ", pledged:", pledgedM);
        assertEq(pledged, pledgedM);

        pledgeAmtUserTotal = 150;
        pledgeAmtUserTotalM = crowdfund.pledgedAmount(campaignId, chaz);
        console.log("pledgeAmtUserTotal:", pledgeAmtUserTotalM);
        assertEq(pledgeAmtUserTotal, pledgeAmtUserTotalM);

        //--------------==
        vm.warp(time + campaignDuration + 5 seconds);
        tokBalc1 = erc20.balanceOf(alice);
        console.log("tokBalc1:", tokBalc1);

        vm.prank(alice);
        crowdfund.claim(campaignId);
        tokBalc = erc20.balanceOf(alice);
        console.log("tokBalc:", tokBalc);
        assertEq(tokBalc1 + pledged, tokBalc);
    }
}
