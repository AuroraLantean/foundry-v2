// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/**
 * AbiEncode to encode calldata, to call Token contract
 */
interface IERC20 {
    function transfer(address, uint256) external;
}

contract Token {
    function transfer(address, uint256) external view {
        console.log("transfer()");
    }
}

contract AbiEncode {
    function callContractFunc(address _contract, bytes calldata data) external {
        (bool ok,) = _contract.call(data);
        require(ok, "call failed");
    }

    //be careful of function signature typo, and arg types
    function encodeWithSignature(address to, uint256 amount) external pure returns (bytes memory) {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    //be careful of arg types
    function encodeWithSelector(address to, uint256 amount) external pure returns (bytes memory) {
        // Type is not checked - (IERC20.transfer.selector, true, amount)
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    // BEST error proof
    function encodeCall(address to, uint256 amount) external pure returns (bytes memory) {
        // Typo and type errors will not compile
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}
