// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/FlashloanClientAave.sol";
import "src/FlashloanDex.sol";

interface IWETH_dup {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

contract FlashloanClientAaveTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    bool ok;
    IWETH_dup public weth;
    FlashloanClientAave client;
    ERC20DP6 usdc;
    //ERC20DP6 usdt;
    ERC20Token dai;
    FlashloanDex dex;
    address flashloanDexAddrM;
    uint256 amount;
    address daiAddrM;
    address ownerM;
    uint256 balcUSDC;
    uint256 balcUSDCm;
    uint256 delta;
    uint256 loanAmount;
    uint256 loanAmountM;
    uint256 feeAmount;
    uint256 balcBobM;
    uint256 balcAliceM;
    uint256 approvalAmount;
    uint256 approvedAmount;
    uint256 liquidityUsdcAmt;
    uint256 liquidityDaiAmt;
    //https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses ... Sepolia
    address poolAddressesProviderAave = 0x0496275d34753A48320CA58103d5220d394FF77F;
    //https://staging.aave.com/faucet/?marketName=proto_sepolia_v3
    address daiAddr = 0x68194a729C2450ad26072b3D33ADaCbcef39D574;
    address usdcAddr = 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f;
    address usdtAddr = 0x0Bd5F04B456ab34a2aB3e9d556Fe5b3A41A0BC8D;

    address payable dexAddr = payable(0x1fe62386FF102eF40F61b9d9320d2CCA220d00D8);
    address payable clientAddr = payable(0x90A7688FFC8aFcFD2f280981E57c2816Eb9B3738);

    address fox1;
    // Computes the address for a given private key.
    // uint256 privateKey = 123;
    // address fox = vm.addr(privateKey);

    function setUp() external {
        console.log("---------== Setup()");
        //weth = IWETH_dup(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //deployed on Mainnet https://etherscan.io/token/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

        vm.startPrank(alice);
        //USDT, USDC use 6 dp !!! But DAI has 18!!
        usdc = ERC20DP6(usdcAddr);
        //usdt = ERC20DP6(usdtAddr);
        dai = ERC20Token(daiAddr);

        dex = FlashloanDex(dexAddr);
        client = FlashloanClientAave(clientAddr);
        vm.stopPrank();

        fox1 = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        console.log("fox1:", fox1);

        loanAmount = 1000000000; //1000 USDC
        console.log("loanAmount:", loanAmount);
        //loanAmount = 1000000; //1 USDC
        feeAmount = loanAmount * 5 / 10000; // 0.0005
        console.log("feeAmount: ", feeAmount);

        approvalAmount = 1300;
        console.log("approvalAmount: ", approvalAmount);

        liquidityUsdcAmt = 1500 * 1e6;
        liquidityDaiAmt = 1500 * 1e18;
        vm.startPrank(fox1);
        usdc.transfer(clientAddr, feeAmount);
        usdc.transfer(dexAddr, liquidityUsdcAmt);
        dai.transfer(dexAddr, liquidityDaiAmt);
        client.approveUSDC(approvalAmount * 1e6);
        client.approveDAI(approvalAmount * 1e18);
        vm.stopPrank();
    }

    function test_1_init() external {
        console.log("----== test_1_init");

        balcUSDCm = usdc.balanceOf(fox1);
        console.log("balcUSDCm on fox1:", balcUSDCm);

        balcUSDCm = usdc.balanceOf(clientAddr);
        console.log("balcUSDCm on clientAddr:", balcUSDCm);

        approvedAmount = usdc.allowance(clientAddr, dexAddr);
        console.log("USDC approvedAmount:", approvedAmount);

        approvedAmount = dai.allowance(clientAddr, dexAddr);
        console.log("DAI  approvedAmount:", approvedAmount);

        loanAmountM = client.loanAmount();
        console.log("loanAmountM:", loanAmountM);
        assertEq(loanAmountM, loanAmount);

        flashloanDexAddrM = address(client.dex());
        console.log("flashloanDexAddrM:", flashloanDexAddrM);
        assertEq(flashloanDexAddrM, dexAddr);
    }

    function test_2_flashloan1() external {
        console.log("----== test_2_flashloan1");
        vm.prank(fox1);
        client.requestFlashLoan(usdcAddr, loanAmount);

        balcUSDCm = usdc.balanceOf(fox1);
        console.log("balcUSDCm on fox1:", balcUSDCm);

        balcUSDCm = usdc.balanceOf(clientAddr);
        console.log("balcUSDCm on clientAddr:", balcUSDCm);
    }
}
