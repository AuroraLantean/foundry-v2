// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract MultiDelegatecall {
    error DelegatecallFailed(uint256 i);

    function multiDelegatecall(bytes[] memory data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);

        for (uint256 i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed(i);
            }
            results[i] = res;
        }
    }
}

// alice -> multi call --- call ---> dest (msg.sender = multi call)
// alice -> delegatecall ---> dest (msg.sender = alice)
contract MultiDelegatecallDest is MultiDelegatecall {
    event Log(address indexed caller, string indexed func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        // msg.sender = alice
        console.log("func1() sender:", msg.sender, x + y);
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint256) {
        // msg.sender = alice
        console.log("func2() sender:", msg.sender);
        emit Log(msg.sender, "func2", 2);
        return 222;
    }

    mapping(address => uint256) public balanceOf;

    // WARNING: unsafe code when used in combination with multi-delegatecall: msg.value is repeatedly used for each call... user can mint multiple times for the price of msg.value
    function mint() external payable {
        console.log("mint() sender:", msg.sender);
        emit Log(msg.sender, "mint", msg.value);
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint256 x, uint256 y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(MultiDelegatecallDest.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(MultiDelegatecallDest.func2.selector);
    }

    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(MultiDelegatecallDest.mint.selector);
    }
}
