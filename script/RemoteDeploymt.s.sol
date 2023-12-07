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

contract RemoteDeploymtScript is Script {
    uint256 public choice;
    string public url;
    uint256 public balcEthB4;
    uint256 public balcEthAf;
    uint256 public balcTokB4;
    uint256 public balcTokAf;
    uint256 public nftBalc;
    /**
     * For Arbitrum, convert some ETH into Arbitrum ETH:
     * https://bridge.arbitrum.io/?l2ChainId=421613
     * https://goerli.arbiscan.io
     */

    function setUp() public {}

    //default function to run in scripts
    function run() public {
        url = vm.rpcUrl("sepolia"); //get the RPC_URL from foundry.toml: [rpc_endpoints]
        console.log("url:", url);
        /*url = vm.rpcUrl("optimism");
        console.log("url:", url);
        url = vm.rpcUrl("arbitrum");
        console.log("url:", url); */

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        vm.startBroadcast(privateKey);
        //vm.broadcast();
        console.log("choice:", choice, ", deployed from: %s", owner);
        uint256 minNftId = 0;
        uint256 maxNftId = 9;
        choice = 4;
        if (choice == 0) {
            console.log("do nothing");
            //console2_log(p0, p1);
        } else if (choice == 1) {
            ERC20Token goldtoken = new ERC20Token("GoldCoin", "GOLC");
            console.log("GoldCoin addr:", address(goldtoken));
            balcTokB4 = goldtoken.balanceOf(owner);
            console.log("owner GoldCoin balc:", balcTokB4, balcTokB4 / 1e18);
        } else if (choice == 2) {
            ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG", minNftId, maxNftId);
            balcTokB4 = dragons.balanceOf(owner);
            console.log("owner NFT balc:", balcTokB4);
        } else if (choice == 3) {
            ERC20DP6 usdt = new ERC20DP6("TetherUSD", "USDT");
            console.log("USDT addr:", address(usdt));
            balcTokB4 = usdt.balanceOf(owner);
            console.log("owner USDT balc:", balcTokB4, balcTokB4 / 1e6);
        } else if (choice == 4) {
            address erc20Addr = vm.envAddress("TOKEN_ADDR");
            console.log("TOKEN_ADDR:", erc20Addr);
            address dragonsAddr = vm.envAddress("NFT_ADDR");
            console.log("NFT_ADDR:", dragonsAddr);
            //uint256 priceInWeiEth = 1e15;
            //uint256 priceInWeiToken = 100e6;
            ERC721Sales sales = new ERC721Sales(erc20Addr);
            address salesAddr = address(sales);
            console.log("Sales addr:", salesAddr);

            ERC721Token dragons = ERC721Token(dragonsAddr);
            dragons.safeApproveBatch(salesAddr, minNftId, maxNftId);
            nftBalc = dragons.balanceOf(salesAddr);
            console.log("Sales nftBalc:", nftBalc);

            //priceArray = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
            //ETH prices: 1000000000000000, 1100000000000000, 1200000000000000, 1300000000000000, 1400000000000000, 1500000000000000, 1600000000000000, 1700000000000000, 1800000000000000, 1900000000000000
            //TokenDp6 prices: 10000000, 11000000, 12000000, 13000000, 14000000, 15000000, 16000000, 17000000, 18000000, 19000000
            //sales.setPriceBatch(nftAddr, minNftId, maxNftId, isETH, priceArray);
        }
        vm.stopBroadcast();
    }
}
