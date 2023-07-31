// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Helper {
    function getBytecode() external pure returns (bytes memory) {
        bytes memory bytecode = type(Ctrt1).creationCode;
        return bytecode;
    }

    //for contracts with constructor arguments, we need to append those arguments to the bytecode
    function getBytecodeWithArgs(uint256 _x, uint256 _y) external pure returns (bytes memory) {
        bytes memory bytecode = type(Ctrt2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_x, _y));
    }

    //for calling Ctrt1.setOwner()
    function getCalldata(string calldata funcSig, address _owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature(funcSig, _owner);
    }
}

contract DeployBytecode {
    event Deploy(address);

    receive() external payable {}

    function deployBytecode(bytes memory _code) external payable returns (address addr) {
        assembly {
            // make(v, p, n)
            // v = amount of ETH to send
            // p = pointer in memory to start of code. We need to tell Solidity where the start of the code is. The first 32 bytes encodes the lenghth of the code. So we need to skip the first 32 bytes(32 in decimal is 0x20 in hexidecimal)
            // n = size of code, which is stored in the first 32 bytes of _code... use mload(_code)
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        // return address 0 on error
        require(addr != address(0), "deploy failed");

        emit Deploy(addr);
    }

    function execute(address _target, bytes memory _data) external payable {
        (bool success,) = _target.call{value: msg.value}(_data);
        require(success, "failed");
    }
}

contract Ctrt1 {
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }
}

contract Ctrt2 {
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) payable {
        x = _x;
        y = _y;
    }
}
