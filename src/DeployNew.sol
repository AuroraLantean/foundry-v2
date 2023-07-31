// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Car {
    address public owner;
    uint256 public num;

    constructor(address _owner, uint256 _num) payable {
        owner = _owner;
        num = _num;
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    function setNum(uint256 _num) public {
        require(msg.sender == owner, "not owner");
        num = _num;
    }
}

contract CtrtFactory {
    Car[] public cars;

    function deploy(address _owner, uint256 _num) public {
        Car car = new Car(_owner, _num);
        cars.push(car);
    }

    function deployWithEther(address _owner, uint256 _num) public payable {
        Car car = (new Car){value: msg.value}(_owner, _num);
        cars.push(car);
    }

    function deployWithSalt(address _owner, uint256 _num, bytes32 _salt) public {
        //salt can be uint... saltB32 = bytes32(saltUint)
        Car car = (new Car){salt: _salt}(_owner, _num);
        cars.push(car);
    }

    function deployWithSaltAndEther(address _owner, uint256 _num, bytes32 _salt) public payable {
        //salt can be uint... saltB32 = bytes32(saltUint)
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _num);
        cars.push(car);
    }

    //---------------== Calculate deployment address
    // 1. Get bytecode of contract to be deployed
    // NOTE: _owner and _num are arguments of the target ctrt's constructor
    function getBytecodeWithArgs(address _owner, uint256 _num) public pure returns (bytes memory) {
        bytes memory bytecode = type(Car).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner, _num));
    }
    // Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    // the return address should be the same as deployWithSalt()

    function getDeploymentAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))); //address(this) is the deployer address

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function getCar(uint256 _index) public view returns (address owner, uint256 num, uint256 balance) {
        Car car = cars[_index];

        return (car.owner(), car.num(), address(car).balance);
    }
}
