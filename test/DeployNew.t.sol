// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/DeployNew.sol";

contract DeployBytecode2Test is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address ctrtFactoryAddr;
    address ctrtAddr;
    address deploymentAddr;
    address deploymentAddrM;
    bytes bytecode;
    uint256 num;
    uint256 salt;

    Car car;
    CtrtFactory ctrtFactory;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        ctrtFactory = new CtrtFactory();
        ctrtFactoryAddr = address(ctrtFactory);
        console.log("deployBytecode:", ctrtFactoryAddr);
    }

    function testDeploy1() public {
        console.log("---------== testDeploy1");
        num = 123;
        salt = 777;
        bytecode = ctrtFactory.getBytecodeWithArgs(alice, num);
        deploymentAddr = ctrtFactory.getDeploymentAddress(bytecode, salt);
        console.log("deploymentAddr :", deploymentAddr);

        ctrtFactory.deployWithSalt(alice, num, bytes32(salt));
        car = ctrtFactory.cars(0);
        deploymentAddrM = address(car);
        console.log("deploymentAddrM:", deploymentAddrM);
        assertEq(deploymentAddr, deploymentAddrM);
    }
}
