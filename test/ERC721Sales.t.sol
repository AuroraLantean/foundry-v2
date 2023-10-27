// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";
import "src/ERC721Token.sol";
import "src/ERC721Sales.sol";

contract ERC721SalesTest is Test, ERC721Holder {
    address public zero = address(0);
    address public alice = address(1);
    address public bob = address(2);
    address public eve = address(5);
    address public tis = address(this);
    ERC721Sales public sales;
    ERC721Token public dragons;
    ERC20DP6 public usdt;
    ERC20Token public token0;
    ArrayOfStructs public ctrt;
    address public owner;
    address public salesAddr;
    address public tokenAddr;
    uint256 public aGenBf;
    uint256 public aGenAf;
    uint256 public aNftBf;
    uint256 public aNftAf;
    uint256 public cGenBf;
    uint256 public cGenAf;
    uint256 public cNftBf;
    uint256 public cNftAf;
    uint256 public amount = 1000;
    uint256 public priceInWeiEth = 1e15;
    uint256 public tokenDp = 1e6;
    uint256 public priceInWeiToken = 100 * tokenDp;
    uint256 public minTokenId = 0;
    uint256 public maxTokenId = 9;
    //IWETH_dup public weth;

    receive() external payable {
        console.log("ETH received from:", msg.sender);
        console.log("ETH received in Szabo:", msg.value / 1e12);
    }

    function setUp() external {
        console.log("---------== Setup()");
        deal(alice, 1 ether);
        deal(bob, 1 ether);
        aGenBf = alice.balance;
        console.log("Alice ETH:", aGenBf);
        aGenBf = bob.balance;
        console.log("Bob ETH:", aGenBf);

        //USDT, USDC use 6 dp !!! But DAI has 18!!
        usdt = new ERC20DP6("TetherUSD", "USDT");
        dragons = new ERC721Token("DragonsNFT", "DRAG", minTokenId, maxTokenId);
        usdt.mint(alice, 1000e6);
        aGenBf = usdt.balanceOf(alice);
        console.log("Alice USDT:", aGenBf);
        assertEq(aGenBf, 1000e6);
        tokenAddr = address(usdt);
        sales = new ERC721Sales(tokenAddr, address(dragons), priceInWeiEth, priceInWeiToken);
        salesAddr = address(sales);
    }

    function _balc(address user, string memory userName, address tokenCtrt, string memory nameTheOther)
        private
        view
        returns (uint256 uTok, uint256 uNft, uint256 cTok, uint256 cNft)
    {
        address theOther = salesAddr;
        if (tokenCtrt == zero) {
            cTok = theOther.balance;
            cNft = dragons.balanceOf(theOther);
            console.log("%s ETH in Szabo: %s, NFT: %s", nameTheOther, cTok / 1e12, cNft);

            uTok = user.balance;
            uNft = dragons.balanceOf(user);
            console.log("%s ETH in Szabo: %s, NFT: %s", userName, uTok / 1e12, uNft);
        } else {
            cTok = usdt.balanceOf(theOther);
            cNft = dragons.balanceOf(theOther);
            console.log("%s usdt: %s, NFT: %s", nameTheOther, cTok / tokenDp, cNft);

            uTok = usdt.balanceOf(user);
            uNft = dragons.balanceOf(user);
            console.log("%s usdt: %s, NFT: %s", userName, uTok / tokenDp, uNft);
        }
    }

    function testInit() external {
        console.log("----== testInit");
        console.log("safeApproveBatch...");
        dragons.safeApproveBatch(salesAddr, 0, 9);

        for (uint256 i = 0; i <= 9; i++) {
            address approvedOptr = dragons.getApproved(i);
            //console.log("approved operator: ", approvedOptr);
            assertEq(approvedOptr, salesAddr);
        }
        /*dragons.safeTransferFromBatch(tis, salesAddr, 0, 9);
        aNft = dragons.balanceOf(salesAddr);
        console.log("aNft:", aNft);
        assertEq(aNft, 10); */

        console.log("--------== buyNFTviaERC20");
        (aGenBf, aNftBf, cGenBf, cNftBf) = _balc(alice, "Alice", tokenAddr, "SalesCtrt");
        vm.startPrank(alice);
        usdt.approve(salesAddr, priceInWeiToken);
        sales.buyNFTviaERC20(0);
        vm.stopPrank();
        (aGenAf, aNftAf, cGenAf, cNftAf) = _balc(alice, "Alice", tokenAddr, "SalesCtrt");
        assertEq(aGenBf - aGenAf, priceInWeiToken);
        assertEq(aNftAf - aNftBf, 1);
        assertEq(cGenAf - cGenBf, priceInWeiToken);

        uint256[] memory out = sales.getBalances();
        console.log("out:", out[0], out[1], out[2]);

        console.log("--------== withdrawERC20");
        (aGenBf, aNftBf, cGenBf, cNftBf) = _balc(tis, "tis", tokenAddr, "SalesCtrt");
        sales.withdrawERC20(tis, usdt.balanceOf(salesAddr));
        (aGenAf, aNftAf, cGenAf, cNftAf) = _balc(tis, "tis", tokenAddr, "SalesCtrt");
        assertEq(aGenAf, aGenBf + priceInWeiToken);

        console.log("--------== BuyNFTviaETH");
        (aGenBf, aNftBf, cGenBf, cNftBf) = _balc(alice, "Alice", zero, "SalesCtrt");
        vm.startPrank(alice);
        sales.buyNFTviaETH{value: priceInWeiEth}(1);
        vm.stopPrank();
        (aGenAf, aNftAf, cGenAf, cNftAf) = _balc(alice, "Alice", zero, "SalesCtrt");
        assertEq(aGenBf - aGenAf, priceInWeiEth);
        assertEq(aNftAf - aNftBf, 1);
        assertEq(cGenAf - cGenBf, priceInWeiEth);

        console.log("--------== withdrawETH");
        (aGenBf, aNftBf, cGenBf, cNftBf) = _balc(tis, "tis", zero, "SalesCtrt");
        sales.withdrawETH(payable(tis), cGenAf);
        console.log("after withdrawETH");
        (aGenAf, aNftAf, cGenAf, cNftAf) = _balc(tis, "tis", zero, "SalesCtrt");
        assertEq(cGenAf, 0);
        assertEq(aGenAf - aGenBf, priceInWeiEth);
    }

    function testOthers() public {
        console.log("----== ArrayOfStructs");
        ctrt = new ArrayOfStructs(100);

        uint256 id = 0;
        ArrayOfStructs.Box memory box;
        box = ctrt.getBox(id);
        console.log("getBox:", id, box.num, box.owner);
        box = ctrt.getBox2(id);
        console.log("getBox2:", id, box.num, box.owner);

        id = 3;
        bool oBool = ctrt.addBox(id, 100 + id, tis);
        console.log("oBool:", oBool);
        box = ctrt.getBox(id);
        console.log("getBox:", id, box.num, box.owner);

        ArrayOfStructs.Box[] memory boxes;
        boxes = ctrt.getBoxes(0, 3);
        console.log("getBoxes. out length:", boxes.length);
        console.log(boxes[0].num, boxes[1].num, boxes[2].num, boxes[3].num);

        boxes = ctrt.getBoxes2(0, 3);
        console.log("getBoxes. out length:", boxes.length);
        console.log(boxes[0].num, boxes[1].num, boxes[2].num, boxes[3].num);

        uint256[] memory uints;
        uints = ctrt.getBalances(tokenAddr);
        console.log("getBalances:", uints[0], uints[1], uints[2]);
    }
}
