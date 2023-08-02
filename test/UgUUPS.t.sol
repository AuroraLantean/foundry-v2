// SPDX-License-Identifier: MIT

/// @title Universal Upgradeability test contract
/// @notice Unit tests for upgradeability of a contract
/// @author Matin Rezaii (@MatinR1) & Behrouz Torabi (@BehrouzT)
/// @dev This test contract is built using Foundry framework

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/UgUUPS.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";

/**
 * @dev This contract inherits the Forge's built-in Test contract.
 * @notice ERC1967 minimal proxy is just used to demonstrate the condition bypassing in the UUPS contract
 */
contract UgUUPSTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    address hacker = address(6);
    bool ok;
    Implettn impl;
    ImplettnV2 impl2;
    ImplettnHack implHack;
    ProxyZ proxy;
    ProxyZ proxy2;
    bytes data;
    address implAddr;
    address implAddr2;
    address implemttnAddrM;
    address imptHackAddr;
    address proxyAddr;
    address ownerM;
    uint8 initVersion;
    uint256 delta;
    uint256 num1;
    uint256 num1M;
    uint256 num2;
    uint256 num2M;

    using Clones for address;

    bytes32 internal constant EIP1967_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function setUp() external {
        console.log("---------== Setup()");
        num1 = 101;
        data = abi.encodeWithSignature("initialize(uint256)", num1); /* invoke ERC1967Proxy() > ERC1967Proxy:
          _upgradeToAndCall(_logic, _data, false);
          ...
          _upgradeTo(newImplettn);
          if (data.length > 0 || forceCall) {
              Address.functionDelegateCall(newImplettn, data);
          }
          ... Address.sol: functionDelegateCall(target, data, "Address: low-level delegate call failed");
          ... (bool success, bytes memory returndata) = target.delegatecall(data);
          ... address(impl).delegatecall(data);// to make delegatecall on implementation/initialize() from Proxy!*/
        vm.startPrank(alice);
        impl = new Implettn();
        implAddr = address(impl);

        impl2 = new ImplettnV2();
        implAddr2 = address(impl2);

        proxy = new ProxyZ(implAddr, data);
        vm.stopPrank();
        proxyAddr = address(proxy);
    }

    /**
     * @notice This function checks two conditions:
     *  1 - The implementation contract has state values
     *  2 - The proxy contract has variables values
     */
    function test_1initializable() external {
        console.log("----== test_1initializable");
        console.log("values from implementation");
        ownerM = impl.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, zero);

        num1M = impl.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, 0);

        initVersion = impl.getInitialized();
        console.log("initVersion:", initVersion);
        assertEq(initVersion, 255); //_disableInitializers();

        console.log("values from proxy");
        impl = Implettn(proxyAddr);
        ownerM = impl.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = impl.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);

        initVersion = impl.getInitialized();
        console.log("initVersion:", initVersion);
        assertEq(initVersion, 1);
        console.log("Implettn has no state values, but the Proxy has state values");

        delta = 10;
        impl.inc(delta);
        num1M = impl.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1 + delta);
        num1 = num1 + delta;

        num1 = 102;
        impl.setNum1(num1);
        num1M = impl.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);

        vm.expectRevert("Initializable: contract is already initialized");
        vm.prank(hacker);
        (ok,) = proxyAddr.call(abi.encodeWithSignature("initialize(uint256)", num1));
        console.log("ok:", ok);
        assertEq(ok, true);
        console.log("hackers cannot re-initialize the implementation");

        bytes32 proxySlot = vm.load(proxyAddr, EIP1967_SLOT);
        assertEq(proxySlot, bytes32(uint256(uint160(implAddr))));
        console.log("EIP1967_SLOT in Proxy holds the implementation address");
    }

    //tests the upgradeability mechanism of the contracts
    function test_3UpgradeImplementation() external {
        console.log("----== test_3UpgradeImplementation");
        vm.startPrank(hacker);
        implHack = new ImplettnHack();
        imptHackAddr = address(implHack);

        vm.expectRevert();
        proxy.upgradeTo(imptHackAddr);
        vm.stopPrank();
        console.log("hacker cannot upgrade");
        //impl.initialize(num1);//Must prevent hacker to initialize first

        console.log("implAddr:       ", implAddr);
        implemttnAddrM = proxy.getImplementation();
        console.log("implemttnAddrM: ", implemttnAddrM);
        assertEq(implAddr, implemttnAddrM);
        //bytes32 proxySlot = vm.load(proxyAddr, EIP1967_SLOT);
        //assertEq(proxySlot, bytes32(uint256(uint160(implAddr))));

        //-----------== Invoke upgradeTo()
        console.log("Invoke upgradeTo()");
        vm.prank(alice);
        proxy.upgradeTo(implAddr2);
        console.log("implAddr2:      ", implAddr2);
        implemttnAddrM = proxy.getImplementation();
        console.log("implemttnAddrM: ", implemttnAddrM);
        assertEq(implAddr2, implemttnAddrM);

        impl2 = ImplettnV2(proxyAddr);
        console.log("values from proxy");
        ownerM = impl2.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);

        initVersion = impl2.getInitialized();
        console.log("initVersion:", initVersion);
        assertEq(initVersion, 1);

        console.log("After upgradeTo(), the Proxy keeps its original state values");

        delta = 13;
        impl2.inc(delta);
        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1 + delta);
        num1 = num1 + delta;

        delta = 5;
        impl2.dcr(delta);
        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1 - delta);
        num1 = num1 - delta;

        num2 = 17;
        impl2.setNum2(num2);
        num2M = impl2.num2();
        console.log("num2M:", num2M);
        assertEq(num2M, num2);

        console.log("Upgrade is successful!");
    }

    function test_4upgradeToAndCallUUPS() external {
        console.log("----== test_4upgradeToAndCallUUPS");
        console.log("implAddr:       ", implAddr);
        implemttnAddrM = proxy.getImplementation();
        console.log("implemttnAddrM: ", implemttnAddrM);
        assertEq(implAddr, implemttnAddrM);

        //-----------== Invoke upgradeToAndCallUUPS()
        console.log("Invoke upgradeToAndCallUUPS()");
        vm.prank(alice);
        proxy.upgradeToAndCallUUPS(implAddr2, "", false);
        console.log("implAddr2:      ", implAddr2);
        implemttnAddrM = proxy.getImplementation();
        console.log("implemttnAddrM: ", implemttnAddrM);
        assertEq(implAddr2, implemttnAddrM);

        impl2 = ImplettnV2(proxyAddr);
        console.log("values from proxy");
        ownerM = impl2.owner();
        console.log("ownerM:", ownerM);
        assertEq(ownerM, alice);

        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1);

        console.log("After upgradeToAndCallUUPS(), the Proxy keeps its original state values");

        delta = 13;
        impl2.inc(delta);
        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1 + delta);
        num1 = num1 + delta;

        delta = 5;
        impl2.dcr(delta);
        num1M = impl2.num1();
        console.log("num1M:", num1M);
        assertEq(num1M, num1 - delta);
        num1 = num1 - delta;

        num2 = 17;
        impl2.setNum2(num2);
        num2M = impl2.num2();
        console.log("num2M:", num2M);
        assertEq(num2M, num2);

        console.log("Upgrade is successful!");
    }

    /**
     * @notice This function creates an attack scenario to upgrade the contract to a malicious contract. As the implementation contract is not initialized at first, we'll try to upgrade the contract to a malicious contract.
     */
    function test_2uninitializedImplAttack() external {
        console.log("----== test_2uninitializedImplAttack");
        // now the malicious person becomes an authorized pesron for the implementation contract
        // Let's try to change the EIP1967_SLOT address of proxy to a new contract
        vm.expectRevert("Initializable: contract is already initialized");
        vm.startPrank(hacker);
        impl.initialize(num1);
        assertEq(impl.owner(), zero);
        console.log("hacker to initialize implementation first");

        proxy2 = new ProxyZ(implAddr, "");

        vm.expectRevert("Function must be called through delegatecall");
        impl.upgradeTo(implAddr2);

        vm.expectRevert("Function must be called through active proxy");
        (ok,) = address(proxy2).delegatecall(abi.encodeWithSignature("upgradeTo(address)", implAddr2));
        console.log("ok:", ok);

        // Let's try to bypass the preceding conditions with minimal proxies
        address implClone = Clones.clone(implAddr);
        vm.expectRevert("Function must be called through active proxy");
        Implettn(implClone).upgradeTo(implAddr2);
        vm.stopPrank();
        /*  The first condition is bypassed however the second one is persistent!
            It illustrates that if a contract inherits the UUPSUpgradeable.sol contract
            the upgradeTo() couldn't be performed via malicious attacks as it includes
            two strong conditions.
         */
    }
}
