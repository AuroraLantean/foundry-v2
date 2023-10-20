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

contract CounterScript is Script {
    uint256 public choice = 0;
    string public url;

    /**
     * For Arbitrum, convert some ETH into Arbitrum ETH:
     * https://bridge.arbitrum.io/?l2ChainId=421613
     * https://goerli.arbiscan.io
     */
    function setUp() public {}

    //default function to run in scripts
    function run() public {
        url = vm.rpcUrl("optimism");
        console.log("url:", url);
        url = vm.rpcUrl("arbitrum");
        console.log("url:", url);

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        //vm.broadcast();
        if (choice == 0) {
            new ERC20Token("GoldCoin", "GOLC");
        } else if (choice == 1) {
            new ERC721Token("DragonsNFT", "DRAG");
        } else if (choice == 2) {
            new ERC20DP6("TetherUSD", "USDT");
        } else if (choice == 2) {
            address usdtAddr = address(0x123);
            address dragonsNFT = address(0x123);
            uint256 priceInWeiEth = 1e18;
            uint256 priceInWeiToken = 100e6;
            new ERC721Sales(usdtAddr, dragonsNFT, priceInWeiEth, priceInWeiToken);
        }
        vm.stopBroadcast();
    }
}
