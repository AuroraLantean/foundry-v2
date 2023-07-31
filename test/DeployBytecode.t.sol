// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/DeployBytecode.sol";

contract DeployBytecodeTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNum = 100;
    address payable deployerAddr;
    string funcSig;

    Helper helper;
    DeployBytecode deployer;
    Ctrt1 ctrt1;
    Ctrt2 ctrt2;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        helper = new Helper();
        console.log("helper:", address(helper));
        deployer = new DeployBytecode();
        deployerAddr = payable(deployer);
        console.log("deployer:", deployerAddr);
    }

    function testDeploy1() public {
        console.log("---------== testDeploy1");
        //console.log("array:", gen.array());

        bytes memory bytecode1 = helper.getBytecode();
        emit log_bytes(bytecode1);

        address addrCtrt1 = deployer.deployBytecode(bytecode1);
        console.log("addrCtrt1:", addrCtrt1);

        ctrt1 = Ctrt1(addrCtrt1);
        address ctrt1_owner = ctrt1.owner();
        console.log("ctrt1_owner:", ctrt1_owner);
        assertEq(ctrt1_owner, deployerAddr);
        console.log("ctrt1_owner is verified");

        vm.prank(alice);
        vm.expectRevert("not owner");
        ctrt1.setOwner(deployerAddr);

        console.log("bytes_setOwner:");
        funcSig = "setOwner(address)";
        bytes memory bytes_setOwner = helper.getCalldata(funcSig, alice);
        emit log_bytes(bytes_setOwner);

        deployer.execute(addrCtrt1, bytes_setOwner);
        address ctrt1_owner2 = ctrt1.owner();
        console.log("ctrt1_owner2:", ctrt1_owner2);
        assertEq(ctrt1_owner2, alice);
        console.log("ctrt1_owner2 is verified as alice");
    }

    function testDeploy2() public {
        console.log("---------== testDeploy2");
        uint256 x = 14;
        uint256 y = 29;
        uint256 etherValue = 123 ether;

        bytes memory bytecode2 = helper.getBytecodeWithArgs(x, y);
        emit log_bytes(bytecode2);

        address addrCtrt2 = deployer.deployBytecode{value: etherValue}(bytecode2);
        console.log("addrCtrt2:", addrCtrt2);

        ctrt2 = Ctrt2(addrCtrt2);
        address ctrt1_owner = ctrt2.owner();
        console.log("ctrt1_owner:", ctrt1_owner);
        assertEq(ctrt1_owner, deployerAddr);
        console.log("ctrt1_owner is verified");

        uint256 etherValueM = ctrt2.value();
        console.log("etherValueM:", etherValueM / 1e18, "ethers");
        assertEq(etherValueM, etherValue);
        console.log("etherValueM is verified");

        uint256 xM = ctrt2.x();
        console.log("x value:", x);
        assertEq(xM, x);
        console.log("x value is verified");

        uint256 yM = ctrt2.y();
        console.log("y value:", y);
        assertEq(yM, y);
        console.log("y value is verified");
    }
}
