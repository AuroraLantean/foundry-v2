// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ErrCtrt {
    error NotAuthorized();
    error TimeNotYetError(uint256 time, uint256 num);

    uint256 public executeTimeMin = 135;

    function throwError() external pure {
        require(false, "not authorized");
    }

    function throwCustomError() external pure {
        revert NotAuthorized();
    }

    function throwCustomErrorWithArg() external view {
        revert TimeNotYetError(block.timestamp, executeTimeMin);
    }

    function succeed() external pure {
        require(true, "not authorized");
    }
}
