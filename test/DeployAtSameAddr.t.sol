// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/DeployAtSameAddr.sol";

contract DeployAtSameAddrTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    DAO dao;
    ProposalCtrt proposalCtrt;
    Attacker attacker;
    DeployerDeployer deployerDeployer;
    Deployer deployer;
    address daoAddr;
    address proposalAddrB4;
    address proposalAddr;
    address attackerAddr;
    address deployerDeployerAddr;
    address deployerAddr;

    uint256 count;
    uint256 num;
    bytes b_get;
    address addrPredicted;
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
        dao = new DAO();
        daoAddr = address(proposalCtrt);

        vm.prank(hacker);
        deployerDeployer = new DeployerDeployer();
        deployerDeployerAddr = address(deployerDeployer);
    }

    function test1() public {
        console.log("---------== test1");
        owner = alice;
        num = 117;
        salt = keccak256(abi.encodePacked(bytes1(0xff), address(this), uint256(123)));

        addrPredicted = deployerDeployer.predictSaltedAddr(salt);
        console.log("addrPredicted:", addrPredicted);

        deployerAddr = deployerDeployer.deploy(salt);
        console.log("deployerAddr:", deployerAddr);
        assertEq(deployerAddr, addrPredicted);

        deployer = Deployer(deployerAddr);
        proposalAddr = deployer.deployProposal();
        console.log("proposalAddr:", proposalAddr);
        proposalAddrB4 = proposalAddr;

        proposalCtrt = ProposalCtrt(proposalAddr);
        proposalCtrt.destruct();
        //assertEq(proposalAddr.code.length, 0);
        deployer.destruct();

        //---------== re-deploy deployer then attacker ctrt
        deployerAddr = deployerDeployer.deploy(salt);
        console.log("deployerAddr:", deployerAddr);
        assertEq(deployerAddr, addrPredicted);

        deployer = Deployer(deployerAddr);
        proposalAddr = deployer.deployProposal();
        console.log("proposalAddr:", proposalAddr);
        assertEq(proposalAddr, proposalAddrB4);
    }
}
