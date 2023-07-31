// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/AuctionDutch.sol";
import "src/ERC721Token.sol";

contract AuctionDutchTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    address nftOwner;
    uint256 num;
    uint256 numM;
    uint256 price;
    uint256 price2;
    uint256 diffPrice;
    uint256 etherValue;
    address addrAppvd;
    address addr2;
    AuctionDutch auction;
    ERC721Token erc721;
    address erc721Addr;
    address auctionAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;

    uint256 duration = 7 days;
    uint256 nftId;
    uint256 startingPrice;
    uint256 startAt;
    uint256 expiresAt;
    uint256 discountRate;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);

        vm.prank(alice);
        erc721 = new ERC721Token("Dragons", "DRG");
        erc721Addr = address(erc721);

        nftId = 7;
        startingPrice = 1e6;
        discountRate = 1; //decreasing amount every second

        vm.prank(alice);
        auction = new AuctionDutch(startingPrice, discountRate, erc721Addr, nftId);
        startAt = auction.startAt();
        price = auction.getPrice();
        console.log("startAt:", startAt, ", price:", price);
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

        price = auction.getPrice();
        console.log("price:", price);
        vm.warp(startAt + 1 days);
        price2 = auction.getPrice();
        diffPrice = price - price2;
        console.log("price:", price2, ", diffPrice:", diffPrice);

        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, alice);
        vm.prank(bob);
        auction.buy{value: price2}();

        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, bob);
    }
}
