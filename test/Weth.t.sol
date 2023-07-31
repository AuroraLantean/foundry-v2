// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Weth.sol";

contract WethTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNumProxy = 5;
    uint256 inputNum = 100;
    uint256 inputValue = 13;
    address payable wethAddr;
    address addr2;
    Weth weth;
    address senderM;
    uint256 ethBalc;
    uint256 ethValue;
    uint256 ethAmt;
    uint256 wethBalc;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);
        weth = new Weth();
        wethAddr = payable(weth);
    }

    function testSendEthViaDeposit() public {
        console.log("---------== testSendEthViaDeposit");
        ethValue = 3 ether;
        ethAmt = 1 ether; //to withdraw

        vm.prank(alice);
        weth.deposit{value: ethValue}();
        ethBalc = weth.getBalance();
        console.log("ethValue: ", ethValue, ", ethBalc: ", ethBalc);
        assertEq(ethValue, ethBalc);

        wethBalc = weth.balanceOf(alice);
        console.log("wethBalc: ", wethBalc);
        assertEq(wethBalc, ethValue);

        console.log("----------== testWithdraw");
        uint256 walletBalcBf = address(weth).balance;
        uint256 aliceBalcBf = alice.balance;
        console.log("walletBalcBf:", walletBalcBf / 1e18, ", aliceBalcBf:", aliceBalcBf / 1e18);

        vm.prank(alice);
        weth.withdraw(ethAmt);

        uint256 walletBalcAf = address(weth).balance;
        uint256 aliceBalcAf = alice.balance;
        console.log("walletBalcAf:", walletBalcAf / 1e18, ", aliceBalcAf:", aliceBalcAf / 1e18);

        assertEq(walletBalcAf, walletBalcBf - ethAmt);
        assertEq(aliceBalcAf, aliceBalcBf + ethAmt);
    }

    function testSendEthViaCall() public {
        ethValue = 3 ether;
        vm.prank(alice);
        (bool sent,) = wethAddr.call{value: ethValue}("");
        console.log("sending ether success:", sent);
        assertEq(sent, true);

        ethBalc = weth.getBalance();
        console.log("ethValue: ", ethValue, ", ethBalc: ", ethBalc);
        assertEq(ethValue, ethBalc);

        wethBalc = weth.balanceOf(alice);
        console.log("wethBalc: ", wethBalc);
        assertEq(wethBalc, ethValue);
    }

    // Check how much ETH available on this contract
    function testLogBalance() public view {
        console.log("ETH balance", address(this).balance / 1e18); //ETH balance 79228162513
    }
}
