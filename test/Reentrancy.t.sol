// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Reentrancy.sol";

contract ReentrancyTest is Test {
    EtherStore public etherStore;
    //EtherStore2 public etherStore2;
    Attack public attack;
    //Attack public attack2;
    address alice = address(1);
    address bob = address(2);
    address eve = address(5);

    function setUp() public {
        etherStore = new EtherStore();
        //etherStore2 = new EtherStore2();
        attack = new Attack(address(etherStore));
        //attack2 = new Attack2(address(etherStore2));
        deal(alice, 1 ether);
        deal(bob, 1 ether);
        deal(eve, 1 ether);
        getBalances();
        assertEq(alice.balance, 1e18);
        assertEq(bob.balance, 1e18);
        assertEq(eve.balance, 1e18);
    }

    // Receive ETH from etherStore
    receive() external payable {}

    //---------== Test sending ETH to EtherStore contract
    // Check how much ETH available for test
    function getBalances() private view {
        console.log("test file ETH balc:", address(this).balance / 1e18); //ETH balance 79228162513
        console.log("Alice ETH balc:", alice.balance / 1e18);
        console.log("Bob ETH balc:", bob.balance / 1e18);
        console.log("Eve ETH balc:", eve.balance / 1e18);
        uint256 ctrtEthBalc = address(etherStore).balance;
        console.log("ctrt ETH balc:", ctrtEthBalc / 1e18);
        uint256 attackEthBalc = address(attack).balance;
        console.log("attack ETH balc:", attackEthBalc / 1e18);
    }

    function _sendToWalletCtrt(uint256 amount) private {
        console.log("_sendToWalletCtrt...");
        (bool ok,) = address(etherStore).call{value: amount}("");
        require(ok, "send ETH failed");
    }

    // Examples of deal and hoax
    // deal(address, uint) - Set balance of address
    // hoax(address, uint) - deal + prank
    function testAttack() public {
        console.log("testDepositEth...");
        vm.prank(alice);
        etherStore.deposit{value: 1 ether}();
        uint256 ctrtEthBalc = etherStore.getBalance();
        assertEq(ctrtEthBalc, 1e18);
        uint256 aliceBalc = etherStore.balances(alice);
        assertEq(aliceBalc, 1e18);

        vm.prank(bob);
        etherStore.deposit{value: 1 ether}();
        ctrtEthBalc = etherStore.getBalance();
        console.log("ctrt ETH balc:", ctrtEthBalc / 1e18);
        assertEq(ctrtEthBalc, 2e18);
        uint256 bobBalc = etherStore.balances(bob);
        assertEq(bobBalc, 1e18);

        console.log("before attack");
        vm.prank(eve);
        attack.attack{value: 1 ether}();
        console.log("after attack");
        //assertEq(ctrtEthBalc, 2e18);
        getBalances();
    }
}
