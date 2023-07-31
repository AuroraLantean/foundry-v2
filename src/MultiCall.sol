// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

//contract that aggregates multiple queries using a for loop and staticcall.
contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory results)
    {
        require(targets.length == data.length, "target length != data length");

        results = new bytes[](data.length);

        for (uint256 i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, string(abi.encodePacked("call failed at i =", Strings.toString(i))));
            results[i] = result;
        }
    }
}

contract MultiCallDest {
    function func1() external view returns (uint256, uint256) {
        return (1, block.timestamp);
    }

    function func2() external view returns (uint256, uint256) {
        return (2, block.timestamp);
    }

    function getFuncData(uint256 _i) external pure returns (bytes memory byt) {
        if (_i == 1) {
            byt = abi.encodeWithSelector(this.func1.selector, _i);
        } else {
            byt = abi.encodeWithSelector(this.func2.selector, _i);
        }
        //same as abi.encodeWithSignature("func1()");
    }

    function funcUint(uint256 _i) external pure returns (uint256) {
        return _i;
    }

    function getfuncUintData(uint256 _i) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.funcUint.selector, _i); //same as abi.encodeWithSignature("funcUint()");
    }
}
