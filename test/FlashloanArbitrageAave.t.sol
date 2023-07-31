// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/FlashloanArbitrageAave.sol";

contract FlashloanArbitrageAaveTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    bool ok;
    FlashLoanArbitrage flashLoanArbitrage;
    ERC20Token dai;
    ERC20Token usdc;
    bytes data;
    address proxyERC20Addr;
    address flashLoanArbitrageAddr;
    address daiAddr;
    address usdcAddr;
    address daiAddrM;
    address ownerM;
    uint256 delta;
    uint256 num1;
    uint256 num1M;
    uint256 amount1;
    uint256 balcBobM;
    uint256 balcAliceM;
    //https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses ... Sepolia
    address poolAddressesProviderAave = 0x0496275d34753A48320CA58103d5220d394FF77F;
    
    function setUp() external {
        console.log("---------== Setup()");
        num1 = 11;
        //vm.createSelectFork(vm.envString("GOERLI_ALCHEMY_SECRET_URL"),block_number);
        vm.startPrank(alice);
        dai = new ERC20Token("DAI", "DAI");
        daiAddr = address(dai);

        usdc = new ERC20Token("USDC", "USDC");
        usdcAddr = address(usdc);

        flashLoanArbitrage = new FlashLoanArbitrage(poolAddressesProviderAave);
        flashLoanArbitrageAddr = address(flashLoanArbitrage);
        
        amount1 = 1000;
        dai.mint(alice, amount1);
        dai.mint(bob, amount1);
        dai.approve(flashLoanArbitrageAddr, amount1);
        vm.stopPrank();

        vm.prank(bob);
        dai.approve(flashLoanArbitrageAddr, amount1);
    }

    function test_1_init() external {
        console.log("----== test_1_init");

        console.log("values from proxyERC20");
        ownerM = dai.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        balcAliceM = dai.balanceOf(alice);
        console.log("balcAliceM:", balcAliceM);
        assertEq(balcAliceM, amount1);

        balcBobM = dai.balanceOf(bob);
        console.log("balcBobM:", balcBobM);
        assertEq(balcBobM, amount1);
    }

    //tests the upgradeability mechanism of the contracts
    function test_3_Upgrade() external {
        console.log("----== test_3_Upgrade");
//daiStakingHack daiStakingHack;

    }
}
