// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC721Token.sol";

contract ERC721TokenTest is Test {
    ERC721Token public erc721;
    ERC721Receiver public erc721receiver;
    address erc721Addr;
    address erc721receiverAddr;
    address ctrtOwner;
    address nftOwner;
    address alice = address(1);
    address bob = address(2);
    address charlie = address(3);
    uint256 nftBalc;
    uint256 nftId;
    uint256 nftIdMin = 10;
    uint256 nftIdMax = 19;
    bytes4 b4;

    function setUp() public {
        vm.prank(alice);
        erc721 = new ERC721Token("Dragons", "DRG");
        erc721Addr = address(erc721);
        console.log("erc721Addr:", erc721Addr);
        ctrtOwner = erc721.owner();
        assertEq(ctrtOwner, alice);
        //console.log("ctrtOwner:", ctrtOwner);

        vm.prank(alice);
        erc721receiver = new ERC721Receiver();
        erc721receiverAddr = address(erc721receiver);
        console.log("erc721receiverAddr:", erc721receiverAddr);
        console.log("setup successful");
    }

    function testSafeMint() public {
        vm.prank(alice);
        erc721.safeMint(bob, nftIdMin);
        nftOwner = erc721.ownerOf(nftIdMin);
        assertEq(nftOwner, bob);
        nftBalc = erc721.balanceOf(bob);
        assertEq(nftBalc, 1);
    }

    function testSafeTransferFromEOA() public {
        vm.prank(alice);
        erc721.safeMint(bob, nftIdMin);
        vm.startPrank(bob);
        erc721.safeTransferFrom(bob, charlie, nftIdMin);
        nftOwner = erc721.ownerOf(nftIdMin);
        assertEq(nftOwner, charlie);
        nftBalc = erc721.balanceOf(charlie);
        assertEq(nftBalc, 1);
    }

    function testSafeTransferFromReceiver() public {
        nftId = 0;
        vm.startPrank(alice);
        erc721.safeTransferFrom(alice, erc721receiverAddr, nftId);
        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, erc721receiverAddr);

        b4 = erc721receiver.makeBytes();
        console.logBytes4(b4);
        b4 = erc721receiver.makeBytes2();
        console.logBytes4(b4);

        erc721receiver.safeTransferFrom(erc721Addr, erc721receiverAddr, charlie, nftId);
        nftOwner = erc721.ownerOf(nftId);
        console.log("nftOwner:", nftOwner);
        assertEq(nftOwner, charlie);
        nftBalc = erc721.balanceOf(charlie);
        console.log("nftBalc:", nftBalc);
        assertEq(nftBalc, 1);
    }

    function testSafeMintBatch() public {
        vm.prank(alice);
        erc721.safeMintBatch(bob, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(bob);
        console.log("nftBalc:", nftBalc);
        assertEq(nftBalc, nftIdMax - nftIdMin + 1);
    }

    function testSafeTransferFromBatch() public {
        vm.prank(alice);
        erc721.safeMintBatch(bob, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(charlie);
        assertEq(nftBalc, 0);
        vm.startPrank(bob);
        erc721.safeTransferFromBatch(bob, charlie, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(charlie);
        assertEq(nftBalc, nftIdMax - nftIdMin + 1);
    }

    function testFail() public {
        vm.prank(alice);
        erc721.safeMint(bob, nftIdMin);
        vm.prank(charlie);
        erc721.burn(nftIdMin);
    }

    function testOnlyOwnerBurn() public {
        vm.prank(alice);
        erc721.safeMint(bob, nftIdMin);

        vm.prank(charlie);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        erc721.burn(nftIdMin);
        emit log_address(charlie);
        emit log_address(bob);
    }
}
