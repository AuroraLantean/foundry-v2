// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/WETH.sol";

// Topics
// - handler based testing - test functions under specific conditions
// - target contract
// - target functions to call via selector

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

// acting as an user
contract Handler is CommonBase, StdCheats, StdUtils {
    WETH private weth;
    uint256 public wethBalance;
    uint256 public numCalls;

    constructor(WETH _weth) {
        weth = _weth;
    }

    receive() external payable {}

    function sendToFallback(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        (bool ok,) = address(weth).call{value: amount}("");
        require(ok, "sendToFallback failed");
    }

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        weth.deposit{value: amount}();
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(address(this)));
        wethBalance -= amount;
        numCalls += 1;

        weth.withdraw(amount);
    }

    function fail() external pure {
        revert("fail");
    }
}

contract WETH_Handler_Based_Invariant_Tests is Test {
    WETH public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH();
        handler = new Handler(weth);

        // Send 100 ETH to handler
        deal(address(handler), 100 * 1e18);
        console.log("weth ETH balance", address(weth).balance / 1e18);
        console.log("handler ETH balance", address(handler).balance / 1e18);

        //-----------== Target Contract
        // Set fuzzer to only call the handler contract, not WETH contract, so test revert number should be 0
        targetContract(address(handler));

        //-----------== Target Selector: to avoid calling certain functions that will cause test failure
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.withdraw.selector;
        selectors[2] = Handler.sendToFallback.selector;

        // Handler.fail() not called
        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
    }

    //xyz is greater than or equal to abc
    function invariant_eth_balance() public {
        assertEq(address(weth).balance, handler.wethBalance());
        console.log("handler num calls", handler.numCalls());
    }
}
