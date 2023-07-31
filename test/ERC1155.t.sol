// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC1155oz.sol";

contract ERC1155ozTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    ERC1155oz erc1155oz;
    ERC1155Receiver erc1155Receiver;
    address erc1155ozAddr;
    address erc1155ReceiverAddr;

    string uri;
    uint256 count;
    uint256 num;
    bytes b_get;
    address owner;
    bytes32 salt;
    uint256 tokId1;
    uint256 tokenId2;
    uint256 initBalance;
    uint256 tok1Balc;
    uint256 tok2Balc;
    uint256 txnAmt;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        uri = "https://doman.com/erc1155/lptoken/uri";
        vm.startPrank(alice);
        erc1155oz = new ERC1155oz(uri);
        erc1155ozAddr = address(erc1155oz);

        erc1155Receiver = new ERC1155Receiver(erc1155oz);
        erc1155ReceiverAddr = address(erc1155Receiver);

        tokId1 = 1;
        tokenId2 = 2;
        initBalance = 9000;
        erc1155oz.mint(alice, tokId1, initBalance, "");
        vm.stopPrank();
    }

    function test1() public {
        console.log("---------== test1");
        tok1Balc = erc1155oz.balanceOf(alice, tokId1);
        console.log("tok1Balc:", tok1Balc);
        assertEq(tok1Balc, initBalance);

        txnAmt = 4000;
        vm.prank(alice);
        erc1155oz.safeTransferFrom(alice, erc1155ReceiverAddr, tokId1, txnAmt, "");

        tok1Balc = erc1155oz.balanceOf(alice, tokId1);
        console.log("tok1Balc:", tok1Balc);
        assertEq(tok1Balc, initBalance - txnAmt);

        tok1Balc = erc1155oz.balanceOf(erc1155ReceiverAddr, tokId1);
        console.log("tok1Balc:", tok1Balc);
        assertEq(tok1Balc, txnAmt);

        txnAmt = 4000;
        vm.prank(alice);
        erc1155Receiver.safeTransferFrom(erc1155ozAddr, erc1155ReceiverAddr, alice, tokId1, txnAmt, "");

        tok1Balc = erc1155oz.balanceOf(alice, tokId1);
        console.log("tok1Balc:", tok1Balc);
        assertEq(tok1Balc, initBalance);

        tok1Balc = erc1155oz.balanceOf(erc1155ReceiverAddr, tokId1);
        console.log("tok1Balc:", tok1Balc);
        assertEq(tok1Balc, 0);
    }
}
