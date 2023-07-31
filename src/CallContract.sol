// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
//https://solidity-by-example.org/sending-ether/

contract Callee {
    uint256 public x;
    uint256 public value;

    function setX(uint256 _x) public returns (uint256) {
        x = _x;
        return x;
    }

    function setXandReceiveEther(uint256 _x) public payable returns (uint256, uint256) {
        x = _x;
        value = msg.value;
        return (x, value);
    }

    function getXandValue() external view returns (uint256, uint256) {
        return (x, value);
    }
}

contract Caller {
    //pass Callee _callee to skip Ctrt(addr_ctrt)
    function setX(Callee _callee, uint256 _x) public {
        //Callee callee = Callee(_addr);
        uint256 x = _callee.setX(_x);
        console.log("setX()... x: ", x);
    }

    // low-level call is not recommended.
    function setXandSendEther(Callee _callee, uint256 _x) public payable {
        (uint256 x, uint256 value) = _callee.setXandReceiveEther{value: msg.value}(_x);
        console.log("setXandSendEther()... x: ", x, " value: ", value);
    }

    function getXandValue(Callee _callee) public view returns (uint256 x, uint256 value) {
        (x, value) = _callee.getXandValue();
        console.log("setXandSendEther()... x: ", x, " value: ", value);
    }
}
