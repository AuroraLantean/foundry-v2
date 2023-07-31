// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/**
 * abi.encode encodes data into bytes.
 * abi.decode decodes bytes back into data.
 */
contract AbiDecode {
    event Log(address indexed caller, string indexed func, uint256 i);

    struct Item {
        string name;
        uint256[2] nums;
    }

    function encode(uint256 x, address addr, uint256[] calldata arr, Item calldata item)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(x, addr, arr, item);
    }

    function decode(bytes calldata data)
        external
        pure
        returns (uint256 x, address addr, uint256[] memory arr, Item memory item)
    {
        // (uint x, address addr, uint[] memory arr, Item item) = ...
        (x, addr, arr, item) = abi.decode(data, (uint256, address, uint256[], Item));
    }

    function func1(uint256 x, uint256 y) external {
        // msg.sender = alice
        console.log("func1() sender:", msg.sender, x + y);
        emit Log(msg.sender, "func1", x + y);
    }
}

contract Helper {
    function getFunc1Data(uint256 x, uint256 y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiDecode.func1.selector, x, y);
    }
}
