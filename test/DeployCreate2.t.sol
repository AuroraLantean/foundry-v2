// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/DeployCreate2.sol";

contract DeployAtSameAddrTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    Factory factory;
    Ctrt ctrt;
    address factoryAddr;
    address ctrtAddr;

    uint256 count;
    uint256 num;
    bytes b_get;
    address ctrtAddrPredicted;
    address owner;
    bytes32 salt;

    receive() external payable {
        console.log("receive", msg.sender, msg.value);
    }

    function setUp() public {
        deal(alice, 1000 ether); //hoax(addr,uint): deal + prank
        deal(bob, 1000 ether);
        deal(hacker, 1000 ether);

        vm.prank(alice);
        factory = new Factory();
        factoryAddr = address(factory);
    }

    function test1() public {
        console.log("---------== test1");
        owner = alice;
        num = 117;
        salt = keccak256(abi.encodePacked(bytes1(0xff), address(this), uint256(123)));

        ctrtAddrPredicted = factory.predictSaltedAddr(owner, num, salt);
        console.log("ctrtAddrPredicted:", ctrtAddrPredicted);

        ctrtAddr = factory.deploy(owner, num, salt);
        console.log("ctrtAddr:", ctrtAddr);
        assertEq(ctrtAddr, ctrtAddrPredicted);
        //deployerDeployer
    }
}
