// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC721Token.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol"; //includes IERC721Receiver

contract ERC721TokenTest is Test, ERC721Holder {
    ERC721Token public erc721;
    ERC721Receiver public erc721receiver;
    address public erc721Addr;
    address public erc721receiverAddr;
    address public ctrtOwner;
    address public nftOwner;
    address public tis = address(this);
    address public bob = address(2);
    address public charlie = address(3);
    uint256 public nftBalc;
    uint256 public nftId;
    uint256 public nftIdMin = 10;
    uint256 public nftIdMax = 19;
    bytes4 public b4;
    uint256 public minTokenId = 0;
    uint256 public maxTokenId = 9;

    receive() external payable {
        console.log("ETH received from:", msg.sender);
        console.log("ETH received in Szabo:", msg.value / 1e12);
    }

    function setUp() public {
        console.log("---------== Setup()");
        console.log("minTokenId: %s, maxTokenId: %s", minTokenId, maxTokenId);
        erc721 = new ERC721Token("Dragons", "DRG", minTokenId, maxTokenId);
        erc721Addr = address(erc721);
        console.log("erc721Addr:", erc721Addr);
        ctrtOwner = erc721.owner();
        console.log("ctrtOwner:", ctrtOwner);
        console.log("tis:", tis);
        assertEq(ctrtOwner, tis);

        erc721receiver = new ERC721Receiver();
        erc721receiverAddr = address(erc721receiver);
        console.log("erc721receiverAddr:", erc721receiverAddr);
        console.log("setup successful");
    }

    function testSafeMint() public {
        erc721.safeMint(bob, nftIdMin);
        nftOwner = erc721.ownerOf(nftIdMin);
        assertEq(nftOwner, bob);
        nftBalc = erc721.balanceOf(bob);
        assertEq(nftBalc, 1);
    }

    function testSafeMintToGuest() public {
        vm.startPrank(bob);
        erc721.safeMintToGuest(erc721receiverAddr, nftIdMin);
        nftOwner = erc721.ownerOf(nftIdMin);
        assertEq(nftOwner, erc721receiverAddr);
        nftBalc = erc721.balanceOf(erc721receiverAddr);
        assertEq(nftBalc, 1);
    }

    function testSafeTransferFromEOA() public {
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
        erc721.safeTransferFrom(tis, erc721receiverAddr, nftId);
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
        erc721.safeMintBatch(bob, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(bob);
        console.log("nftBalc:", nftBalc);
        assertEq(nftBalc, nftIdMax - nftIdMin + 1);
    }

    function testSafeTransferFromBatch() public {
        erc721.safeMintBatch(bob, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(charlie);
        assertEq(nftBalc, 0);
        vm.startPrank(bob);
        erc721.safeTransferFromBatch(bob, charlie, nftIdMin, nftIdMax);
        nftBalc = erc721.balanceOf(charlie);
        assertEq(nftBalc, nftIdMax - nftIdMin + 1);
    }

    function testFail() public {
        erc721.safeMint(bob, nftIdMin);
        console.log("to test failure1");
        vm.prank(charlie);
        erc721.burn(nftIdMin);
        console.log("failure1"); //not reached
    }

    function testMintTheSameId() public {
        erc721.safeMint(bob, nftIdMin);
        bytes4 selector = bytes4(keccak256("ERC721InvalidSender(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        erc721.safeMint(bob, nftIdMin);
        emit log_address(bob);
    }

    function testOnlyOwnerBurn() public {
        erc721.safeMint(bob, nftIdMin);
        //The caller must own `tokenId` or be an approved operator.
        //error ERC721InsufficientApproval(address operator,uint256 tokenId)
        vm.prank(charlie);
        bytes4 selector = bytes4(keccak256("ERC721InsufficientApproval(address,uint256)")); //keep parameter types, but remove parameter name and any space in between quotes!!!
        vm.expectRevert(abi.encodeWithSelector(selector, charlie, nftIdMin)); //selector and custom error arguments
        erc721.burn(nftIdMin);
        emit log_address(charlie);
        emit log_address(bob);
    }

    function testSetTokenURI() public {
        string memory tokenURI = erc721.tokenURI(minTokenId);
        console.log("tokenURI: ", tokenURI);

        string memory baseTokenURI = "https://abc.com/";
        erc721.setBaseURI(baseTokenURI);
        string memory baseURI = erc721.baseURI();
        console.log("baseURI: ", baseURI);

        tokenURI = erc721.tokenURI(minTokenId);
        console.log("tokenURI: ", tokenURI);
        tokenURI = erc721.tokenURI(minTokenId + 1);
        console.log("tokenURI: ", tokenURI);
        tokenURI = erc721.tokenURI(maxTokenId);
        console.log("tokenURI: ", tokenURI);
    }
}
