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
    uint256 public tokenAmount = 1000;
    uint256 public receivedAmount = 0;
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

    function testTokenReceiver() public {
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

    function testTransferFromEOA() public {
        erc20.mint(bob, tokenAmount);
        vm.prank(bob);
        erc20.transfer(charlie, tokenAmount);
        receivedAmount = erc20.balanceOf(charlie);
        assertEq(receivedAmount, tokenAmount);
    }

    function testSafeTransferFromReceiver() public {
        erc20.transfer(erc20receiverAddr, tokenAmount);
        receivedAmount = erc20.balanceOf(erc20receiverAddr);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, tokenAmount);

        b4 = erc20receiver.makeBytes();
        console.logBytes4(b4);
        b4 = erc20receiver.makeBytes2();
        console.logBytes4(b4);

        erc20receiver.transfer(erc20Addr, charlie, tokenAmount);
        receivedAmount = erc20.balanceOf(charlie);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, tokenAmount);
    }

    // function testFail() public { }

    function testBurn() public {
        erc20.mint(bob, tokenAmount);

        //only account with enough balance can burn
        receivedAmount = erc20.balanceOf(charlie);
        vm.prank(charlie);
        bytes4 selector = bytes4(keccak256("ERC20InsufficientBalance(address,uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, charlie, receivedAmount, tokenAmount));
        erc20.burn(tokenAmount);
        emit log_address(charlie);
        emit log_address(bob);

        vm.prank(bob);
        erc20.burn(tokenAmount);
        receivedAmount = erc20.balanceOf(bob);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, 0);
    }

    function testMint() public {
        tokenAmount = 1000;
        uint8 decimals = erc20.decimals();
        console.log("decimals:", decimals);

        //Non owner should not mint
        vm.prank(charlie);
        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, charlie));
        erc20.mint(bob, tokenAmount);

        //Owner(this contract) can mint
        erc20.mint(bob, tokenAmount);
        receivedAmount = erc20.balanceOf(bob);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, tokenAmount);

        //guest can mint 100 tokens
        vm.prank(charlie);
        erc20.mintToGuest();
        receivedAmount = erc20.balanceOf(charlie);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, 100 * 10 ** decimals);
    }
}
