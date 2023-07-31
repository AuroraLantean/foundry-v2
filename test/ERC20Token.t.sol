// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token public erc20;
    ERC20Receiver public erc20receiver;
    address erc20Addr;
    address erc20receiverAddr;
    address ctrtOwner;
    address tokenOwner;
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    uint256 balc;
    uint256 tokenAmount;
    bytes4 b4;

    function setUp() public {
        vm.startPrank(alice);
        erc20 = new ERC20Token("Dragons", "DRG");
        erc20Addr = address(erc20);
        console.log("erc20Addr:", erc20Addr);
        ctrtOwner = erc20.owner();
        assertEq(ctrtOwner, alice);

        erc20receiver = new ERC20Receiver();
        erc20receiverAddr = address(erc20receiver);
        console.log("erc20receiverAddr:", erc20receiverAddr);
        console.log("setup successful");
        vm.stopPrank();
    }

    function test1() public {
        tokenAmount = 1000;
        vm.startPrank(alice);
        erc20.transfer(bob, tokenAmount);
        balc = erc20.balanceOf(bob);
        console.log("Bob balc:", balc);
        assertEq(balc, tokenAmount);

        tokenAmount = 1000;
        erc20.approve(erc20receiverAddr, tokenAmount * 2);
        erc20receiver.deposit(erc20Addr, tokenAmount);
        balc = erc20.balanceOf(erc20receiverAddr);
        console.log("erc20receiverAddr balc:", balc);
        assertEq(balc, tokenAmount);

        erc20receiver.safeDeposit(erc20Addr, tokenAmount);
        balc = erc20.balanceOf(erc20receiverAddr);
        console.log("erc20receiverAddr balc:", balc);
        assertEq(balc, tokenAmount * 2);

        tokenAmount = 250;
        erc20receiver.transfer(erc20Addr, charlie, tokenAmount);
        balc = erc20.balanceOf(charlie);
        console.log("charlie balc:", balc);
        assertEq(balc, tokenAmount);

        console.log("here2");
        erc20receiver.safeTransfer(erc20Addr, charlie, tokenAmount);
        balc = erc20.balanceOf(charlie);
        console.log("charlie balc:", balc);
        assertEq(balc, tokenAmount * 2);

        vm.stopPrank();
    }
    /*
    function testSafeTransferFromEOA() public {
        vm.prank(alice);
        erc20.safeMint(bob);
        vm.startPrank(bob);
        erc20.safeTransferFrom(bob, charlie);
        tokenOwner = erc20.ownerOf(nftIdMin);
        assertEq(tokenOwner, charlie);
        balc = erc20.balanceOf(charlie);
        assertEq(balc, 1);
    }

    function testSafeTransferFromReceiver() public {
        nftId = 0;
        vm.startPrank(alice);
        erc20.safeTransferFrom(alice, erc20receiverAddr, nftId);
        tokenOwner = erc20.ownerOf(nftId);
        console.log("tokenOwner:", tokenOwner);
        assertEq(tokenOwner, erc20receiverAddr);

        b4 = erc20receiver.makeBytes();
        console.logBytes4(b4);
        b4 = erc20receiver.makeBytes2();
        console.logBytes4(b4);

        erc20receiver.safeTransferFrom(erc20Addr, erc20receiverAddr, charlie, nftId);
        tokenOwner = erc20.ownerOf(nftId);
        console.log("tokenOwner:", tokenOwner);
        assertEq(tokenOwner, charlie);
        balc = erc20.balanceOf(charlie);
        console.log("balc:", balc);
        assertEq(balc, 1);
    }

    function testFail() public {
        vm.prank(alice);
        erc20.safeMint(bob);
        vm.prank(charlie);
        erc20.burn(nftIdMin);
    }

    function testOnlyOwnerBurn() public {
        vm.prank(alice);
        erc20.safeMint(bob);

        vm.prank(charlie);
        vm.expectRevert("ERC20: caller is not token owner or approved");
        erc20.burn(nftIdMin);
        emit log_address(charlie);
        emit log_address(bob);
    }
    */
}
