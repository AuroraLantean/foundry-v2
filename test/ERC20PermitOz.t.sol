// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/ERC20PermitOz.sol";
//import "src/ERC20PermitSolmate.sol";

/**
 * to avoid token owners calling ERC20 approve()
 * anyone can call ERC20Permit/permit(...), then their contract can call transferFrom() without approvals.
 */
contract ERC20PermitStakingTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address dave = address(4);

    ERC20PermitOz private token;
    ERC20PermitStaking private erc20PermitStaking;

    address tokenOwner;
    address receiver;
    address txnSender;
    address tokenAddr;
    address stakingAddr;
    address ctrtAddr;
    uint256 tokenAmt;
    uint256 balcTokenOwner;
    uint256 balcTokenOwnerB4;
    uint256 balcStakingCtrt;
    uint256 balcStakingCtrtB4;
    uint256 deadline;
    uint256 constant TOKEN_OWNER_PK = 111;
    uint256 constant fee = 10;
    uint256 balcReceiver;
    uint256 balcTxnSender;

    function setUp() public {
        tokenOwner = vm.addr(TOKEN_OWNER_PK);
        tokenAmt = 1000;

        vm.startPrank(alice);
        token = new ERC20PermitOz("GoldCoin", "GLD");
        tokenAddr = address(token);
        token.mint(tokenOwner, tokenAmt);

        erc20PermitStaking = new ERC20PermitStaking(tokenAddr);
        stakingAddr = address(erc20PermitStaking);
        vm.stopPrank();

        assertEq(tokenOwner.balance, 0);
        assertEq(token.balanceOf(alice), 9000000000 ether);
        assertEq(token.balanceOf(tokenOwner), tokenAmt);
    }

    function test1() public {
        console.log("-------------== test1: deposit tokens gaslessly");
        deadline = block.timestamp + 60;

        // Sender - prepare permit signature
        bytes32 permitHash = _getPermitHash(tokenOwner, stakingAddr, tokenAmt, token.nonces(tokenOwner), deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(TOKEN_OWNER_PK, permitHash);

        console.log("check1");
        balcTokenOwner = token.balanceOf(tokenOwner);
        console.log("balcTokenOwner:", balcTokenOwner);
        assertEq(balcTokenOwner, tokenAmt, "tokenOwner balance");

        balcStakingCtrt = token.balanceOf(stakingAddr);
        console.log("balcStakingCtrt:", balcStakingCtrt);
        assertEq(balcStakingCtrt, 0, "stakingAddr balance");

        console.log("before depositWithPermit...");
        console.log("ETH tokenOwner:", tokenOwner.balance);
        assertEq(tokenOwner.balance, 0);
        vm.prank(tokenOwner);
        erc20PermitStaking.depositWithPermit(tokenAmt, deadline, v, r, s);
        console.log("after depositWithPermit...");
        balcTokenOwner = token.balanceOf(tokenOwner);
        console.log("balcTokenOwner:", balcTokenOwner);
        assertEq(balcTokenOwner, 0, "tokenOwner balance");

        balcStakingCtrt = token.balanceOf(stakingAddr);
        console.log("balcStakingCtrt:", balcStakingCtrt);
        assertEq(balcStakingCtrt, tokenAmt, "stakingAddr balance");
    }

    function test2() public {
        console.log("-------------== test2: send tokens gaslessly");
        receiver = dave;
        txnSender = bob;
        ctrtAddr = stakingAddr;
        vm.startPrank(alice);
        token.mint(tokenOwner, fee);
        assertEq(tokenOwner.balance, 0);
        assertEq(txnSender.balance, 0);
        assertEq(token.balanceOf(tokenOwner), tokenAmt + fee);
        assertEq(token.balanceOf(receiver), 0);
        assertEq(token.balanceOf(txnSender), 0);

        deadline = block.timestamp + 60;

        // Sender - prepare permit signature
        bytes32 permitHash = _getPermitHash(tokenOwner, ctrtAddr, tokenAmt + fee, token.nonces(tokenOwner), deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(TOKEN_OWNER_PK, permitHash);

        console.log("check1");
        balcTokenOwner = token.balanceOf(tokenOwner);
        console.log("balcTokenOwner:", balcTokenOwner);
        assertEq(balcTokenOwner, tokenAmt + fee, "tokenOwner balance");

        balcStakingCtrt = token.balanceOf(ctrtAddr);
        console.log("balcCtrt:", balcStakingCtrt);
        assertEq(balcStakingCtrt, 0, "ctrtAddr balance");

        balcReceiver = token.balanceOf(receiver);
        console.log("balcReceiver:", balcReceiver);
        assertEq(balcReceiver, 0, "receiver balance");

        balcTxnSender = token.balanceOf(txnSender);
        console.log("balcTxnSender:", balcTxnSender);
        assertEq(balcTxnSender, 0, "txnSender balance");

        // Execute gasless.send()
        console.log("ETH txnSender:", txnSender.balance);
        assertEq(txnSender.balance, 0);
        vm.prank(txnSender);
        erc20PermitStaking.send(address(token), tokenOwner, receiver, tokenAmt, fee, deadline, v, r, s);

        console.log("check2");
        balcTokenOwner = token.balanceOf(tokenOwner);
        console.log("balcTokenOwner:", balcTokenOwner);
        assertEq(balcTokenOwner, 0, "tokenOwner balance");

        balcStakingCtrt = token.balanceOf(ctrtAddr);
        console.log("balcCtrt:", balcStakingCtrt);
        assertEq(balcStakingCtrt, 0, "ctrtAddr balance");

        balcReceiver = token.balanceOf(receiver);
        console.log("balcReceiver:", balcReceiver);
        assertEq(balcReceiver, tokenAmt, "receiver balance");

        balcTxnSender = token.balanceOf(txnSender);
        console.log("balcTxnSender:", balcTxnSender);
        assertEq(balcTxnSender, fee, "txnSender balance");
    }
    //copied from ERC20Permit.sol/permit() and add nonce as an argument

    function _getPermitHash(address owner, address spender, uint256 value, uint256 nonce, uint256 _deadline)
        private
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                token.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        value,
                        nonce,
                        _deadline
                    )
                )
            )
        );
    }
}
