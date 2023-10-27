// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/AuctionEnglish.sol";
import "src/ERC721Token.sol";

contract AuctionDutchTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    address nftOwner;
    address highestBidder;
    uint256 num;
    uint256 numM;
    uint256 highestBid;
    uint256 totalEth;
    uint256 price;
    bool isEnd;
    uint256 etherValue;
    address addrAppvd;
    address addr2;
    AuctionEnglish auction;
    ERC721Token erc721;
    address erc721Addr;
    address auctionAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;

    uint256 duration = 7 days;
    uint256 nftId;
    uint256 startingBid;
    uint256 startAt;
    uint256 expiresAt;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        deal(charlie, 1000 ether);

        uint256 minTokenId = 0;
        uint256 maxTokenId = 9;
        vm.prank(alice);
        erc721 = new ERC721Token("Dragons", "DRG", minTokenId, maxTokenId);
        erc721Addr = address(erc721);

        nftId = 7;
        startingBid = 1;

        vm.prank(alice);
        auction = new AuctionEnglish(erc721Addr, nftId, startingBid);
        auctionAddr = address(auction);

        addrAppvd = erc721.getApproved(nftId);
        console.log("addrAppvd:", addrAppvd);
        vm.prank(alice);
        erc721.approve(auctionAddr, nftId);
        addrAppvd = erc721.getApproved(nftId);
        console.log("addrAppvd:", addrAppvd);
        assertEq(addrAppvd, auctionAddr);
    }

    function test1() public {
        console.log("---------== test1");
        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, alice);

        vm.prank(alice);
        auction.start();
        startAt = auction.startAt();
        console.log("alice starts the auction...");
        assertEq(startAt, block.timestamp);

        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, auctionAddr);

        vm.warp(startAt + 1 days);

        price = 10;
        vm.prank(bob);
        auction.bid{value: price}();
        console.log("after Bob bids...");
        highestBidder = auction.highestBidder();
        console.log("highestBidder:", highestBidder);
        assertEq(highestBidder, bob);
        highestBid = auction.highestBid();
        console.log("highestBid:", highestBid);
        assertEq(highestBid, price);

        price = 20;
        vm.prank(charlie);
        auction.bid{value: price}();
        console.log("after charlie bids...");
        highestBidder = auction.highestBidder();
        console.log("highestBidder:", highestBidder);
        assertEq(highestBidder, charlie);
        highestBid = auction.highestBid();
        console.log("highestBid:", highestBid);
        assertEq(highestBid, price);

        price = 30;
        vm.prank(bob);
        auction.bid{value: price}();
        console.log("after Bob bids...");
        highestBidder = auction.highestBidder();
        console.log("highestBidder:", highestBidder);
        assertEq(highestBidder, bob);
        highestBid = auction.highestBid();
        console.log("highestBid:", highestBid);
        assertEq(highestBid, price);

        totalEth = auction.totalLostBids(charlie);
        console.log("Charlie totalLostBids:", totalEth);
        assertEq(totalEth, 20);
        totalEth = auction.totalLostBids(bob);
        console.log("Bob totalLostBids:", totalEth);
        assertEq(totalEth, 10);

        vm.warp(startAt + 7 days + 1 minutes);
        auction.end();
        isEnd = auction.ended();
        console.log("isEnd:", isEnd);
        assertEq(isEnd, true);

        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, bob);

        //---------== withdraw lost bid ETH
        ethBalc = bob.balance;
        vm.prank(bob);
        auction.withdraw();
        assertEq(bob.balance - ethBalc, 10);

        ethBalc = charlie.balance;
        vm.prank(charlie);
        auction.withdraw();
        assertEq(charlie.balance - ethBalc, 20);
    }
}
