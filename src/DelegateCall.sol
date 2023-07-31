// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/**
 * See UpgradeableProxy.sol for more information!
 */
contract Logic2 { // use this ABI at Proxy address
    //MUST have the same slot data as the proxy contract
    address public owner;
    address public sender;
    Logic public logic;
    uint256 public num;
    uint256 public value;
    uint256 public num2; //New variables!
    address public admin; //New variables!
    mapping(address => uint256) shareHolder; //New variables!
    bytes32[] examples; // dynamic array => USE PUSH

    constructor(address _owner) {
        owner = _owner;
    }

    function stake(uint256 _num) public payable {
        console.log("LogicNew.stake()... msg.sender:", msg.sender, "_num:", _num);
        num = doMath(_num);
        sender = msg.sender;
        value = msg.value;
    }

    function doMath(uint256 _num) public pure returns (uint256) {
        return _num * 2;
    }
}

// NOTE: storage layout must be the same as contract Proxy
contract Logic { // use this ABI at Proxy address
    address public owner;
    address public sender;
    Logic public logic;
    uint256 public num;
    uint256 public value;

    constructor(address _owner) {
        owner = _owner;
    }

    function stake(uint256 _num) public payable {
        console.log("Logic.stake()... msg.sender:", msg.sender, "_num:", _num);
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract Proxy {
    address public owner;
    address public sender;
    Logic public logic;
    uint256 public num = 5;
    uint256 public value;

    constructor(address _owner) {
        owner = _owner;
    }

    function stake(address _contract, uint256 _num) public payable {
        console.log("Proxy.stake()... msg.sender:", msg.sender, "_num:", _num);
        // Proxy's storage is set, Logic is not modified.
        /*(bool success, ) = _contract.delegatecall(abi.encodeWithSignature("stake(uint256)", _num));*/
        (bool success,) = _contract.delegatecall(abi.encodeWithSelector(Logic.stake.selector, _num)); //works better if you change the function signature
        console.log("success:", success);
        //console.log("data:", data);
        require(success, "delegatecall failed");
    }

    function updateLogicAddr(address _logicAddr) external {
        logic = Logic(_logicAddr);
    }
}
