// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token public erc20;
    ERC20Receiver public erc20receiver;
    address public erc20Addr;
    address public erc20receiverAddr;
    address public ctrtOwner;
    address public tokenOwner;
    address public tis = address(this);
    address public bob = address(2);
    address public charlie = address(3);
    uint256 public balc;
    uint256 public tokenAmount;
    bytes4 public b4;

    receive() external payable {
        console.log("ETH received from:", msg.sender);
        console.log("ETH received in Szabo:", msg.value / 1e12);
    }

    event TokenReceived(address indexed from, uint256 indexed amount, bytes data);

    bytes4 private constant _ERC20_RECEIVED = 0x8943ec02;
    // Equals to `bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")))`
    // OR IERC20Receiver.tokenReceived.selector

    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4) {
        //console.log("tokenReceived");
        emit TokenReceived(from, amount, data);
        return _ERC20_RECEIVED;
    }

    function setUp() public {
        erc20 = new ERC20Token("Dragons", "DRG");
        erc20Addr = address(erc20);
        console.log("erc20Addr:", erc20Addr);
        ctrtOwner = erc20.owner();
        assertEq(ctrtOwner, tis);

        erc20receiver = new ERC20Receiver();
        erc20receiverAddr = address(erc20receiver);
        console.log("erc20receiverAddr:", erc20receiverAddr);
        console.log("setup successful");
    }

    function test1() public {
        tokenAmount = 1000;
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
    }
    /*
    function testSafeTransferFromEOA() public {
        erc20.safeMint(bob);
        vm.prank(bob);
        erc20.safeTransferFrom(bob, charlie);
        tokenOwner = erc20.balanceOf(amount);
        assertEq(tokenOwner, charlie);
        balc = erc20.balanceOf(charlie);
        assertEq(balc, 1);
    }

    function testSafeTransferFromReceiver() public {
        nftId = 0;
        erc20.safeTransferFrom(tis, erc20receiverAddr, nftId);
        tokenOwner = erc20.balanceOf(nftId);
        console.log("tokenOwner:", tokenOwner);
        assertEq(tokenOwner, erc20receiverAddr);

        b4 = erc20receiver.makeBytes();
        console.logBytes4(b4);
        b4 = erc20receiver.makeBytes2();
        console.logBytes4(b4);

        erc20receiver.safeTransferFrom(erc20Addr, erc20receiverAddr, charlie, nftId);
        tokenOwner = erc20.balanceOf(nftId);
        console.log("tokenOwner:", tokenOwner);
        assertEq(tokenOwner, charlie);
        balc = erc20.balanceOf(charlie);
        console.log("balc:", balc);
        assertEq(balc, 1);
    }

    function testFail() public {
        erc20.safeMint(bob);
        vm.prank(charlie);
        erc20.burn(amount);
    }

    function testOnlyOwnerBurn() public {
        erc20.safeMint(bob);

        vm.prank(charlie);
        vm.expectRevert("ERC20: caller is not token owner or approved");
        erc20.burn(amount);
        emit log_address(charlie);
        emit log_address(bob);
    }
    */
}
