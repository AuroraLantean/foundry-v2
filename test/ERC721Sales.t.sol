// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/ERC721Token.sol";
import "src/ERC721Sales.sol";

contract ERC721SalesTest is Test, ERC721Holder {
    //address zero = address(0);
    address public alice = address(1);
    address public bob = address(2);
    address public hacker = address(6);
    address public tis = address(this);
    ERC721Sales public sales;
    ERC721Token public dragons;
    ERC20DP6 public usdt;
    ERC20Token public token0;
    address public owner;
    address public salesAddr;
    uint256 public balcBobB4;
    uint256 public balcBobAf;
    uint256 public balcEthB4;
    uint256 public balcEthAf;
    uint256 public balcTokB4;
    uint256 public balcTokAf;
    uint256 public balcNftB4;
    uint256 public balcNftAf;
    uint256 public nftBalc;
    uint256 public amount = 1000;
    uint256 public priceInWeiEth = 1e18;
    uint256 public priceInWeiToken = 100e6;
    //uint256 public feeAmount;
    //IWETH_dup public weth;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() external {
        console.log("---------== Setup()");
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        //USDT, USDC use 6 dp !!! But DAI has 18!!
        usdt = new ERC20DP6("TetherUSD", "USDT");
        dragons = new ERC721Token("DragonsNFT", "DRAG");
        usdt.mint(alice, amount);
        usdt.mint(bob, amount);
        //balcAliceB4 = usdt.balanceOf(alice);
        balcBobB4 = usdt.balanceOf(bob);
        console.log("bob USDT balc:", balcBobB4);
        assertEq(balcBobB4, amount);

        sales = new ERC721Sales(address(usdt), address(dragons), priceInWeiEth, priceInWeiToken);
        salesAddr = address(sales);
    }

    function testInit() external {
        console.log("----== testInit");
        dragons.safeTransferFromBatch(tis, salesAddr, 0, 9);
        nftBalc = dragons.balanceOf(salesAddr);
        console.log("nftBalc:", nftBalc);
        assertEq(nftBalc, 10);

        console.log("--------== buyNFTviaERC20");
        balcTokB4 = usdt.balanceOf(tis);
        balcNftB4 = dragons.balanceOf(tis);
        console.log("balcTokB4:", balcTokB4, ", balcNftB4:", balcNftB4);

        usdt.approve(salesAddr, priceInWeiToken);
        sales.buyNFTviaERC20(0);
        balcTokAf = usdt.balanceOf(tis);
        balcNftAf = dragons.balanceOf(tis);
        console.log("balcTokAf:", balcTokAf, ", balcNftAf:", balcNftAf);
        assertEq(balcTokB4 - balcTokAf, priceInWeiToken);
        assertEq(balcNftAf - balcNftB4, 1);

        balcTokAf = usdt.balanceOf(salesAddr);
        console.log("sales balcTokAf:", balcTokAf);
        assertEq(balcTokAf, priceInWeiToken);

        console.log("--------== withdrawERC20");
        balcTokB4 = usdt.balanceOf(tis);
        console.log("balcTokB4:", balcTokB4);
        sales.withdrawERC20(tis, usdt.balanceOf(salesAddr));
        balcTokAf = usdt.balanceOf(tis);
        console.log("balcTokAf:", balcTokAf);
        assertEq(balcTokAf, balcTokB4 + priceInWeiToken);

        console.log("--------== BuyNFTviaETH");
        balcEthB4 = tis.balance;
        balcNftB4 = balcNftAf;
        console.log("balcEthB4:", balcEthB4);

        sales.buyNFTviaETH{value: priceInWeiEth}(1);
        balcEthAf = tis.balance;
        console.log("balcEthAf:", balcEthAf);
        console.log("ETH decrease:", balcEthB4 - balcEthAf);
        balcEthB4 = balcEthAf;

        balcNftAf = dragons.balanceOf(tis);
        console.log("balcNftAf:", balcNftAf);
        //assertEq(balcEthB4 - balcEthAf, priceInWeiEth);
        assertEq(balcNftAf - balcNftB4, 1);

        balcEthAf = salesAddr.balance;
        console.log("sales balcEthAf:", balcEthAf);
        assertEq(balcEthAf, priceInWeiEth);

        console.log("--------== withdrawETH");
        sales.withdrawETH(payable(tis), balcEthAf);
        balcEthAf = salesAddr.balance;
        console.log("sales balcEthAf:", balcEthAf);
        balcEthAf = tis.balance;
        console.log("this balcEthAf:", balcEthAf);
        console.log("ETH increase:", balcEthAf - balcEthB4);
    }
}
