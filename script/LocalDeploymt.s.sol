// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
/**
 * First, it collects all transactions from the script, and only then does it broadcast them all. It can essentially be split into 4 phases:
 * #1 Local Simulation - The contract script is run in a local evm. If a rpc/fork url has been provided, it will execute the script in that context. Any external call (not static, not internal) from a vm.broadcast and/or vm.startBroadcast will be appended to a list.
 *
 * #2 Onchain Simulation - Optional. If a rpc/fork url has been provided, then it will sequentially execute all the collected transactions from the previous phase here.
 *
 * #3 Broadcasting - Optional. If the --broadcast flag is provided and the previous phases have succeeded, it will broadcast the transactions collected at step 1. and simulated at step 2.
 *
 * #4 Verification - Optional. If the --verify flag is provided, there's an API key, and the previous phases have succeeded it will attempt to verify the contract. (eg. etherscan).
 *
 * # Supported RPC Methods
 *   https://book.getfoundry.sh/reference/anvil/
 */

import "src/ERC20Token.sol";
import "src/ERC721Token.sol";
import "src/ERC721Sales.sol";

contract AnvilDeploymtScript is Script {
    address public tis = address(this);
    address public usdtAddr;
    address public dragonsAddr;
    uint256 public choice;
    string public url;
    uint256 public zGenBf;
    uint256 public zGenAf;
    uint256 public nftBalc;
    /**
     * For Arbitrum, convert some ETH into Arbitrum ETH:
     * https://bridge.arbitrum.io/?l2ChainId=421613
     * https://goerli.arbiscan.io
     */

    function setUp() public {}

    //default function to run in scripts
    function run() public {
        uint256 privateKey = vm.envUint("ANVIL4_PRIVATE_KEY");
        address deployer = vm.rememberKey(privateKey);
        uint256 privateKey1 = vm.envUint("ANVIL1_PRIVATE_KEY");
        address anvil1 = vm.rememberKey(privateKey1);
        //vm.envAddress("ANVIL4");
        vm.startBroadcast(privateKey);
        //vm.broadcast();
        choice = 4;
        console.log("choice:", choice);
        if (choice == 0) {
            console.log("do nothing");
            //console2_log(p0, p1);
        } else if (choice == 1) {
            ERC20Token goldtoken = new ERC20Token("GoldCoin", "GOLC");
            console.log("GoldCoin addr:", address(goldtoken));
            zGenBf = goldtoken.balanceOf(deployer);
            console.log("deployer GoldCoin balc:", zGenBf, zGenBf / 1e18);
        } else if (choice == 2) {
            ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG");
            dragonsAddr = address(dragons);
            zGenBf = dragons.balanceOf(deployer);
            console.log("deployer NFT balc:", zGenBf);
        } else if (choice == 3) {
            ERC20DP6 usdt = new ERC20DP6("TetherUSD", "USDT");
            usdtAddr = address(usdt);
            console.log("USDT addr:", usdtAddr);
            zGenBf = usdt.balanceOf(deployer);
            console.log("deployer USDT balc:", zGenBf, zGenBf / 1e6);
        } else if (choice == 4) {
            zGenBf = deployer.balance;
            console.log("deployer:", deployer);
            console.log("deployer ETH balc:", zGenBf, zGenBf / 1e18);

            ERC20DP6 usdt = new ERC20DP6("TetherUSD", "USDT");
            usdtAddr = address(usdt);
            console.log("USDT addr:", usdtAddr);
            zGenBf = usdt.balanceOf(deployer);
            console.log("deployer USDT balc:", zGenBf, zGenBf / 1e6);

            console.log("anvil1:", anvil1);
            usdt.transfer(anvil1, 1000e6);
            zGenBf = usdt.balanceOf(anvil1);
            console.log("anvil1 USDT balc:", zGenBf, zGenBf / 1e6);

            ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG");
            dragonsAddr = address(dragons);
            console.log("DragonsNFT addr:", dragonsAddr);
            zGenBf = dragons.balanceOf(deployer);
            console.log("deployer NFT balc:", zGenBf);

            uint256 priceInWeiEth = 1e15;
            uint256 tokenDp = 1e6;
            uint256 priceInWeiToken = 100 * tokenDp;
            //ERC721Sales _sales =
            ERC721Sales sales = new ERC721Sales(usdtAddr, dragonsAddr, priceInWeiEth, priceInWeiToken);
            address salesAddr = address(sales);
            console.log("Sales addr:", salesAddr);

            dragons.safeApproveBatch(salesAddr, 0, 9);
            for (uint256 i = 0; i <= 9; i++) {
                address approvedOptr = dragons.getApproved(i);
                console.log("approved operator: ", approvedOptr);
            }
            //dragons.safeTransferFromBatch(deployer, salesAddr, 0, 9);
            //nftBalc = dragons.balanceOf(tis);
            //console.log("tis nftBalc:", nftBalc);
            console.log("deployer:", deployer);

            console.log("USDT_ADDR=", usdtAddr);
            console.log("DRAGONS_ADDR=", dragonsAddr);
            console.log("SALES_ADDR=", salesAddr);
        }
        vm.stopBroadcast();
    }
}