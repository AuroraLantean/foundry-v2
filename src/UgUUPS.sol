// SPDX-License-Identifier: MIT
/// @title Implementation and UUPS proxy contracts

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

//import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console.sol";

contract ProxyZ is ERC1967Proxy, Ownable {
    //ERC1967Proxy/constuctor(): assert(EIP1967_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));

    constructor(address impl, bytes memory data) ERC1967Proxy(impl, data) {}

    //------------== ERC1967Upgrade
    function getImplementation() external view returns (address) {
        return super._implementation();
    }

    function upgradeTo(address newImplementation) public onlyOwner {
        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) public onlyOwner {
        _upgradeToAndCall(newImplementation, data, forceCall);
    }

    function upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) public onlyOwner {
        _upgradeToAndCallUUPS(newImplementation, data, forceCall);
    }

    function getAdmin() public view returns (address) {
        return _getAdmin();
    }

    function setAdmin(address _adminNew) external onlyOwner {
        _changeAdmin(_adminNew);
    }
}

contract Implettn is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public num1;

    constructor() {
      //to disable re-initialization. See Initializable.sol
      _disableInitializers();//impl.getInitialized(): 255
    }
    function initialize(uint256 _num) external initializer {
        //called by Proxy via delegatecall so that the variables here are stored in the proxy storage
        //console.log("Implettn/initialize()", msg.sender, _num);
        __UUPSUpgradeable_init();
        __Ownable_init();
        num1 = _num;
    }
    
    function inc(uint256 _b) external {
        num1 += _b;
    }
    function setNum1(uint256 _b) external {
        num1 = _b;
    }

    function getInitialized() external view returns (uint8) {
        return _getInitializedVersion();
    }

    //REQUIRED. to safeguard from unauthorized upgrades because in the UUPS pattern the upgrade is done from the implementation contract
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

//USE inheritance to MAKE SURE the state variables are the same!
contract ImplettnV2 is Implettn {
    uint256 public num2;

    function dcr(uint256 _b) external {
        console.log("dcr");
        num1 -= _b;
    }
    function setNum2(uint256 _b) external {
        num2 = _b;
    }
}
contract ImplettnHack is Implettn {
    //uint256 public num2;

    function attack(uint256 _b) external {
        num1 = _b;
    }
}