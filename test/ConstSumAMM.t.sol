// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/ConstSumAMM.sol";
import "src/ERC20Token.sol";

contract ConstSumAMMTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 tokAmt0;
    uint256 tokAmt0B4;
    uint256 tokAmt1;
    uint256 tokAmt1B4;
    address constSumAMMAddr;
    address token0Addr;
    address token1Addr;
    ConstSumAMM constSumAMM;
    ERC20Token token0;
    ERC20Token token1;
    address senderM;
    uint256 tok0Approved;
    uint256 tok1Approved;
    uint256 tokBalcAlice;
    uint256 tokBalcAliceB4;
    uint256 tokIncrease;
    uint256 tokBalcConstSumAMM;
    uint256 tokProfit;
    uint256 shareBalc;
    uint256 shareBalcB4;
    uint256 addedShares;
    uint256 constSumAMMBalc;
    uint256 totalShares;
    uint256 res0Balc;
    uint256 res0BalcB4;
    uint256 res1Balc;
    uint256 res1BalcB4;
    uint256 tok0BalcBob;
    uint256 tok0BalcBobB4;
    uint256 tok1BalcBob;
    uint256 tok1BalcBobB4;
    uint256 tok0BalcAliceB4;
    uint256 tok1BalcAliceB4;
    uint256 tok0IcrAlice;
    uint256 tok1DcrAlice;
    uint256 tok0DcrBob;
    uint256 tok1IcrBob;
    uint256 tok0BalcAlice;
    uint256 tok1BalcAlice;
    uint256 totalSharesB4;
    uint256 removedShares;
    uint256 shareWithdrawn;
    uint256 shareModifier;
    uint256 tokOutExpected;
    uint256 swapAmtIn;
    uint256 swapAmtOut;
    uint256 res0BalcDiff;
    uint256 res1BalcDiff;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);

        vm.startPrank(alice);
        token0 = new ERC20Token("Token0", "TOK0");
        token0Addr = address(token0);
        console.log("token0Addr:", token0Addr);
        token0.mint(bob, 1000);
        tok0BalcAliceB4 = token0.balanceOf(alice);

        token1 = new ERC20Token("Token1", "TOK1");
        token1Addr = address(token1);
        console.log("token1Addr:", token1Addr);
        token1.mint(bob, 1000);
        tok1BalcAliceB4 = token1.balanceOf(alice);

        constSumAMM = new ConstSumAMM(token0Addr, token1Addr);
        constSumAMMAddr = address(constSumAMM);
        tok0Approved = 1000;
        tok1Approved = 1000;
        token0.approve(constSumAMMAddr, tok0Approved);
        token1.approve(constSumAMMAddr, tok1Approved);
        vm.stopPrank();

        vm.startPrank(bob);
        token0.approve(constSumAMMAddr, tok0Approved);
        token1.approve(constSumAMMAddr, tok1Approved);
        vm.stopPrank();
    }

    function test1() public {
        console.log("---------== test1");
        tokAmt0 = 1000;
        tokAmt1 = 1000;
        console.log("addLiquidity()... tokAmt0:", tokAmt0, ", tokAmt1:", tokAmt1);
        vm.prank(alice);
        constSumAMM.addLiquidity(tokAmt0, tokAmt1);
        shareBalc = constSumAMM.userShares(alice);
        addedShares = tokAmt0 + tokAmt1;
        console.log("Alice shareBalc: ", shareBalc);
        assertEq(shareBalc, addedShares);
        shareBalcB4 = addedShares;

        totalShares = constSumAMM.totalShares();
        console.log("totalShares: ", totalShares);
        assertEq(totalShares, addedShares);

        res0Balc = constSumAMM.reserve0();
        console.log("res0Balc: ", res0Balc);
        assertEq(res0Balc, tokAmt0);

        res1Balc = constSumAMM.reserve1();
        console.log("res1Balc: ", res1Balc);
        assertEq(res1Balc, tokAmt1);

        swapAmtIn = 1000;
        console.log("---------== Bob to swap", swapAmtIn, "token0 for token1");
        tok0BalcBobB4 = token0.balanceOf(bob);
        tok1BalcBobB4 = token1.balanceOf(bob);
        res0BalcB4 = constSumAMM.reserve0();
        res1BalcB4 = constSumAMM.reserve1();

        vm.prank(bob);
        swapAmtOut = constSumAMM.swap(token0Addr, swapAmtIn);
        console.log("swapAmtOut: ", swapAmtOut);
        tok0BalcBob = token0.balanceOf(bob);
        tok1BalcBob = token1.balanceOf(bob);
        console.log("tok0BalcBobB4: ", tok0BalcBobB4, ", tok0BalcBob: ", tok0BalcBob);
        console.log("tok1BalcBobB4: ", tok1BalcBobB4, ", tok1BalcBob: ", tok1BalcBob);
        tok0DcrBob = tok0BalcBobB4 - tok0BalcBob;
        tok1IcrBob = tok1BalcBob - tok1BalcBobB4;
        console.log("Bob tok0 decrease:", tok0DcrBob);
        console.log("Bob tok1 increase:", tok1IcrBob);
        assertEq(tok0DcrBob, swapAmtIn);
        assertEq(tok1IcrBob, swapAmtOut);

        res0Balc = constSumAMM.reserve0();
        res0BalcDiff = res0Balc - res0BalcB4;
        res0BalcB4 = res0Balc;
        console.log("reserve0 increase: ", res0BalcDiff);
        assertEq(res0BalcDiff, swapAmtIn);

        res1Balc = constSumAMM.reserve1();
        res1BalcDiff = res1BalcB4 - res1Balc;
        res1BalcB4 = res1Balc;
        console.log("reserve1 decrease: ", res1BalcDiff);
        assertEq(res1BalcDiff, swapAmtOut);

        console.log("---------== RemoveLiquidity()");
        shareBalc = constSumAMM.userShares(alice);
        console.log("Alice shareBalc: ", shareBalc);
        shareWithdrawn = shareBalc;
        shareBalcB4 = shareBalc;
        console.log("Alice to withdraw", shareWithdrawn, "shares");
        vm.prank(alice);
        constSumAMM.removeLiquidity(shareWithdrawn);
        shareBalc = constSumAMM.userShares(alice);
        removedShares = shareBalcB4 - shareBalc;
        console.log("Alice shareBalc: ", shareBalc, ", removedShares:", removedShares);
        assertEq(shareBalc, shareBalcB4 - shareWithdrawn);

        res0Balc = constSumAMM.reserve0();
        res0BalcDiff = res0BalcB4 - res0Balc;
        res0BalcB4 = res0Balc;
        console.log("res0Balc:", res0Balc, ", reserve0 decrease: ", res0BalcDiff);
        assertEq(res0Balc, 0);

        res1Balc = constSumAMM.reserve1();
        res1BalcDiff = res1BalcB4 - res1Balc;
        res1BalcB4 = res1Balc;
        console.log("res1Balc:", res1Balc, ", reserve1 decrease: ", res1BalcDiff);
        assertEq(res1Balc, 0);

        totalShares = constSumAMM.totalShares();
        console.log("totalShares: ", totalShares);
        assertEq(totalShares, 0);

        console.log("tok0BalcAliceB4:", tok0BalcAliceB4, ", tok1BalcAliceB4: ", tok1BalcAliceB4);

        tok0BalcAlice = token0.balanceOf(alice);
        tok1BalcAlice = token1.balanceOf(alice);
        console.log("tok0BalcAlice:", tok0BalcAlice, ", tok1BalcAlice: ", tok1BalcAlice);

        tok0IcrAlice = tok0BalcAlice - tok0BalcAliceB4;
        tok1DcrAlice = tok1BalcAliceB4 - tok1BalcAlice;
        console.log("Alice tok0 increase:", tok0IcrAlice, ", Alice tok1 decrease:", tok1DcrAlice);

        console.log("Bob tok0 decrease:", tok0DcrBob, ", Bob tok1 increase:", tok1IcrBob);
        assertEq(tok0IcrAlice, tok0DcrBob);
        assertEq(tok1DcrAlice, tok1IcrBob);

        console.log("Alice's profit:", tok0IcrAlice - tok1DcrAlice);
        console.log("end of ConstSumAMM");
    }
}
