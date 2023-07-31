// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/WalletPayable.sol";

contract WalletPayableTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNumProxy = 5;
    uint256 inputNum = 100;
    uint256 inputValue = 13;
    address payable addr1;
    address addr2;
    WalletPayable pwallet;
    SendToFallback stfb;
    FallbackInputOutput fbio;
    address senderM;
    uint256 ethBalc;

    receive() external payable {
        uint256 gasleftO = gasleft();
        console.log("receive", msg.sender, msg.value / 1e18, gasleftO);
    }

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        pwallet = new WalletPayable();
        //pwallet = new WalletPayable{value: 1e18}(); //from address(this)
        stfb = new SendToFallback();
        fbio = new FallbackInputOutput(addr2);
    }
    //-------------------==

    function test1() public {
        console.log("---------== test1");
        uint256 etherValue = 3 ether;
        address addrPC = address(pwallet);

        vm.prank(alice);
        (bool sent,) = addrPC.call{value: etherValue}("");
        console.log("sending ether", sent);
        senderM = pwallet.sender();
        assertEq(senderM, alice);

        ethBalc = pwallet.getBalance();
        assertEq(ethBalc, etherValue);
    }

    //-------------------==
    //---------== Test owner
    function testSetOwner() public {
        pwallet.setOwner(alice);
        assertEq(pwallet.owner(), alice);
    }

    function testFailNotOwner() public {
        vm.prank(alice);
        pwallet.setOwner(alice);
    }

    function testFailSetOwnerAgain() public {
        pwallet.setOwner(alice); //from address(this)

        vm.startPrank(alice);
        pwallet.setOwner(alice);
        vm.stopPrank();
        console.log("owner", pwallet.owner());
        pwallet.setOwner(alice); //from address(this)
        console.log("owner", pwallet.owner());
    }
    // Check how much ETH available on this contract

    function testLogBalance() public view {
        console.log("ETH balance", address(this).balance / 1e18); //ETH balance 79228162513
    }

    function _sendToWalletCtrt(uint256 amount) private {
        (bool ok,) = address(pwallet).call{value: amount}("");
        require(ok, "send ETH failed");
    }

    // Examples of deal and hoax
    // deal(address, uint) - Set balance of address
    // hoax(address, uint) - deal + prank
    function testSendEth() public {
        uint256 bal = address(pwallet).balance;

        // deal
        deal(alice, 100); //Set balance of address
        assertEq(alice.balance, 100);

        deal(alice, 10);
        assertEq(alice.balance, 10);

        // hoax = deal + vm.prank
        deal(alice, 123);
        vm.prank(alice);
        _sendToWalletCtrt(123);
        assertEq(alice.balance, 0);
        assertEq(address(pwallet).balance, bal + 123);

        hoax(alice, 456); //deal + prank
        _sendToWalletCtrt(456);
        assertEq(alice.balance, 0);
        assertEq(address(pwallet).balance, bal + 123 + 456);
    }

    function testFailWithdrawNotOwner() public {
        vm.prank(alice);
        pwallet.withdrawAll();
    }

    // Test fail and check error message
    function testWithdrawNotOwner() public {
        vm.prank(alice);
        vm.expectRevert("not owner");
        pwallet.withdrawAll();
    }

    function testWithdraw() public {
        console.log("----------== testWithdraw");
        uint256 etherValue = 7 ether;
        uint256 etherAmt = 1 ether;
        address addrPC = address(pwallet);

        vm.prank(alice);
        (bool sent,) = addrPC.call{value: etherValue}("");
        console.log("sending ether", sent);

        uint256 walletBalcBf = address(pwallet).balance;
        uint256 ownerBalcBf = address(this).balance;
        console.log("walletBalcBf:", walletBalcBf / 1e18, ", ownerBalcBf:", ownerBalcBf / 1e18);

        pwallet.withdraw(payable(address(this)), etherAmt);

        uint256 walletBalcAf = address(pwallet).balance;
        uint256 ownerBalcAf = address(this).balance;
        console.log("walletBalcAf:", walletBalcAf / 1e18, ", ownerBalcAf:", ownerBalcAf / 1e18);

        assertEq(walletBalcAf, walletBalcBf - etherAmt);
        assertEq(ownerBalcAf, ownerBalcBf + etherAmt);
    }
}
