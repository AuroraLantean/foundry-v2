// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/fLiquidityClientAave.sol";

interface IWETH_dup {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

contract LiquidityClientAaveTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    bool ok;
    IWETH_dup public weth;
    LiquidityClientAave client;
    ERC20DP6 usdc;
    //ERC20DP6 usdt;
    ERC20Token dai;
    ERC20Token token;
    address tokenAddr;
    address tokenAddrM;
    address atokenAddr;
    address atokenAddrM;
    uint256 amount;
    address daiAddrM;
    address ownerM;
    uint256 balcUSDC;
    uint256 balcUSDCm;
    uint256 balcFox1M;
    uint256 delta;
    uint256 liquidityAmt;
    uint256 liquidityAmtM;
    uint256 balcBobM;
    uint256 balcAliceM;
    uint256 balcTokClientM;
    uint256 balcTokAClientM;
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
    address linkTokenAddr = 0x8a0E31de20651fe58A369fD6f76c21A8FF7f8d42;
    address alinkTokenAddr = 0xD21A6990E47a07574dD6a876f6B5557c990d5867;
    address poolAddr;

    address payable clientAddr = payable(0x8b499AB56c4D93b562799150BA9129A896c69caF);

    address fox1;

    function setUp() external {
        console.log("---------== Setup()");
        //weth = IWETH_dup(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //deployed on Mainnet https://etherscan.io/token/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

        tokenAddr = linkTokenAddr;
        atokenAddr = alinkTokenAddr;
        vm.startPrank(alice);
        usdc = ERC20DP6(usdcAddr); //USDC use 6 dp !!!
        //usdt = ERC20DP6(usdtAddr);//USDT use 6 dp !!!
        //dai = ERC20Token(daiAddr);
        token = ERC20Token(tokenAddr);

        client = LiquidityClientAave(clientAddr);
        vm.stopPrank();

        poolAddr = address(client.POOL());

        fox1 = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        console.log("fox1:", fox1);

        liquidityAmt = 500;
        console.log("liquidityAmt:", liquidityAmt / 1e18, liquidityAmt);

        approvalAmount = liquidityAmt;
        console.log("approvalAmount: ", approvalAmount / 1e18, approvalAmount);

        vm.startPrank(fox1);
        token.transfer(clientAddr, liquidityAmt);
        client.approveToken(approvalAmount, poolAddr);
        vm.stopPrank();
    }

    function test_1_init() external {
        console.log("----== test_1_init");

        balcTokClientM = client.getTokenBalance(tokenAddr);
        console.log("balcTokClientM:", balcTokClientM);
        assertEq(balcTokClientM, liquidityAmt);

        tokenAddrM = address(client.token());
        console.log("tokenAddrM:", tokenAddrM);
        assertEq(tokenAddrM, tokenAddr);
    }

    function test_2_addLiquidity() external {
        console.log("----== test_2_addLiquidity");
        vm.prank(fox1);
        client.supplyLiquidity(tokenAddr, liquidityAmt);

        balcTokClientM = client.getTokenBalance(tokenAddr);
        console.log("balcTokClientM:", balcTokClientM);
        assertEq(balcTokClientM, 0);
        balcTokAClientM = client.getTokenBalance(atokenAddr);
        console.log("balcTokAClientM:", balcTokAClientM);
        assertGe(balcTokAClientM, liquidityAmt);

        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = client.getUserAccountData(clientAddr);
        console.log("totalCollateralBase:", totalCollateralBase);
        console.log("totalDebtBase:", totalDebtBase);
        console.log("availableBorrowsBase:", availableBorrowsBase);
        console.log("currentLiquidationThreshold:", currentLiquidationThreshold);
        console.log("ltv:", ltv);
        console.log("healthFactor:", healthFactor);

        client.withdrawlLiquidity(tokenAddr, type(uint256).max);

        balcTokClientM = client.getTokenBalance(tokenAddr);
        console.log("balcTokClientM:", balcTokClientM);
        assertGe(balcTokClientM, liquidityAmt);
        balcTokAClientM = client.getTokenBalance(atokenAddr);
        console.log("balcTokAClientM:", balcTokAClientM);
        assertEq(balcTokAClientM, 0);
    }

    // function test_3_others() external {
    //     console.log("----== test_3_others");
    //     vm.prank(fox1);
    // }
}
