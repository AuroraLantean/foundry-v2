// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/UgERC20.sol";
import "src/UgUUPS.sol";

contract UgERC20Test is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    bool ok;
    ProxyZ proxyStaking;
    ProxyZ proxyERC20;
    ERC20UToken erc20U;
    ERC20UTokenV2 erc20UV2;
    ERC20UTokenHack erc20UHack;
    ERC20UStaking erc20UStaking;
    ERC20UStakingV2 erc20UStakingV2;
    ERC20UStakingHack erc20UStakingHack;
    bytes data;
    address proxyERC20Addr;
    address proxyStakingAddr;
    address erc20UAddr;
    address erc20UAddrV2;
    address erc20UAddrM;
    address erc20UHackAddr;
    address erc20UStakingAddr;
    address erc20UStakingAddrM;
    address erc20UStakingV2Addr;
    address erc20UStakingHackAddr;
    address ownerM;
    uint8 initVersion;
    uint256 version;
    uint256 versionM;
    uint256 delta;
    uint256 num1;
    uint256 num1M;
    uint256 stakedAmt;
    uint256 stakedAmtM;
    uint256 withdrawnAmt;
    uint256 withdrawnAmtM;
    uint256 amount1;
    uint256 balcBobM;
    uint256 balcAliceM;
    uint256 stakedBob;
    uint256 stakedBobM;
    uint256 stakedBobB4;

    function setUp() external {
        console.log("---------== Setup()");
        num1 = 11;

        vm.startPrank(alice);
        erc20U = new ERC20UToken();
        erc20UAddr = address(erc20U);
        //erc20U.initialize("token1", "TOK1");

        erc20UV2 = new ERC20UTokenV2();
        erc20UAddrV2 = address(erc20UV2);

        erc20UStaking = new ERC20UStaking();
        erc20UStakingAddr = address(erc20UStaking);
        //erc20UStaking.initialize(erc20UAddr);

        erc20UStakingV2 = new ERC20UStakingV2();
        erc20UStakingV2Addr = address(erc20UStakingV2);

        data = abi.encodeWithSignature("initialize(string,string)", "GoldCoin", "GLVC");
        proxyERC20 = new ProxyZ(erc20UAddr, data);
        proxyERC20Addr = address(proxyERC20);
        console.log("proxyERC20Addr:", proxyERC20Addr);
        //MUST instantiate the contract at the proxy addr
        erc20U = ERC20UToken(proxyERC20Addr);

        data = abi.encodeWithSignature("initialize(address)", erc20UAddr);
        proxyStaking = new ProxyZ(erc20UStakingAddr, data);
        proxyStakingAddr = address(proxyStaking);
        console.log("proxyStakingAddr:", proxyStakingAddr);
        //MUST instantiate the contract at the proxy addr
        erc20UStaking = ERC20UStaking(proxyStakingAddr);

        amount1 = 1000;
        erc20U.mint(alice, amount1);
        erc20U.mint(bob, amount1);
        erc20U.approve(proxyStakingAddr, amount1);
        vm.stopPrank();

        vm.prank(bob);
        erc20U.approve(proxyStakingAddr, amount1);
    }

    function test_1_init() external {
        console.log("----== test_1_init");

        console.log("values from proxyERC20");
        ownerM = erc20U.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = erc20U.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, 5);

        console.log("values from erc20UStaking");
        ownerM = erc20UStaking.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = erc20UStaking.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, 11);

        balcAliceM = erc20U.balanceOf(alice);
        console.log("balcAliceM:", balcAliceM);
        assertEq(balcAliceM, amount1);

        balcBobM = erc20U.balanceOf(bob);
        console.log("balcBobM:", balcBobM);
        assertEq(balcBobM, amount1);
    }

    //tests the upgradeability mechanism of the contracts
    function test_3_Upgrade() external {
        console.log("----== test_3_Upgrade");
        //ERC20UStakingHack erc20UStakingHack;
        vm.startPrank(hacker);
        erc20UStakingHack = new ERC20UStakingHack();
        erc20UStakingHackAddr = address(erc20UStakingHack);

        vm.expectRevert();
        proxyStaking.upgradeTo(erc20UStakingHackAddr);
        vm.stopPrank();
        console.log("hacker cannot upgrade");
        //erc20U.initialize(num1);//Must prevent hacker to initialize first

        console.log("erc20UStakingAddr:  ", erc20UStakingAddr);
        erc20UStakingAddrM = proxyStaking.getImplementation();
        console.log("erc20UStakingAddrM: ", erc20UStakingAddrM);
        assertEq(erc20UStakingAddr, erc20UStakingAddrM);

        //erc20UStaking  erc20U, proxyERC20Addr
        stakedAmt = 1000;
        vm.prank(bob);
        erc20UStaking.stake(proxyERC20Addr, stakedAmt);
        stakedBobM = erc20UStaking.staked(bob);
        console.log("stakedBobM:", stakedBobM);
        assertEq(stakedBobM, stakedAmt);

        //-----------== Invoke upgradeTo()
        console.log("Invoke upgradeTo()");
        vm.prank(alice);
        proxyStaking.upgradeTo(erc20UStakingV2Addr);
        console.log("erc20UStakingV2Addr:", erc20UStakingV2Addr);

        erc20UStakingAddrM = proxyStaking.getImplementation();
        console.log("erc20UStakingAddrM: ", erc20UStakingAddrM);
        assertEq(erc20UStakingV2Addr, erc20UStakingAddrM);

        //MUST re-instantiate the new contract at the proxy addr
        erc20UStakingV2 = ERC20UStakingV2(proxyStakingAddr);
        console.log("values from proxyStaking");
        ownerM = erc20UStakingV2.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = erc20UStakingV2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);
        console.log("After upgradeTo(), the ERC20UStaking keeps its original state values");

        num1 = 13;
        vm.prank(alice);
        erc20UStakingV2.setVersion(num1);
        num1M = erc20UStakingV2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);

        //erc20UStakingV2  erc20U, proxyERC20Addr
        stakedBobM = erc20UStakingV2.staked(bob);
        console.log("stakedBobM:", stakedBobM);
        assertEq(stakedBobM, stakedAmt);
        stakedBobB4 = stakedBobM;

        withdrawnAmt = 1000;
        vm.prank(bob);
        erc20UStakingV2.withdraw(proxyERC20Addr, withdrawnAmt);
        stakedBobM = erc20UStakingV2.staked(bob);
        console.log("stakedBobM:", stakedBobM);
        assertEq(stakedBobM, stakedBobB4 - withdrawnAmt);

        balcBobM = erc20U.balanceOf(bob);
        console.log("balcBobM:", balcBobM);
        assertEq(balcBobM, amount1);
    }
    /**
     * erc20UV2 = ERC20UTokenV2(proxyERC20Addr);
     *     balcBobM = erc20UV2.balanceOf(bob);
     *     console.log("balcBobM:", balcBobM);
     *     assertEq(balcBobM, amount1);
     */
}
