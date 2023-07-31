// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/**
 * Transparent upgradeable proxy pattern
 * admin EOA --> ProxyAdmin/upgrade()
 *           --> Proxy/upgrade()
 *
 * user EOA  --> ProxyAdmin/fallback() + delegatecall
 *           --> implementation Ctrt
 *
 * # MUST have the same slot data as the proxy contract: Storage for implementation and admin
 * # read data...
 *
 * Separate user and admin interfaces
 * Proxy admin
 *
 * Shortcoming: cannot return data correctly
 */
contract CounterV1 {
    uint256 public count;

    function inc() external {
        count += 1;
    }

    function admin() external pure returns (address) {
        return address(7);
    }

    function implementation() external pure returns (address) {
        return address(8);
    }
}

contract CounterV2 is CounterV1 {
    uint256 public owner;
    mapping(address => uint256) shareHolder; //New variables!
    bytes32[] examples; // dynamic array => USE PUSH

    function dec() external {
        count -= 1;
    }
}

contract Proxy {
    // All functions / variables should be private, forward all calls to fallback

    // -1 for unknown preimage
    // 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    // this slot location is selected by us to store our variable
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    // 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    //if both the proxy and the implementation contracts have the same special functions or variable names: "admin" and "implementation", the the proxy's functions will take precedence!... Solution: use ifAdmin to divert admin to call the proxy contract's special functions, but users to call  the implementation contract! ... but this makes another problem: the admin cannot access the implementation contract... The solution: make a proxyAdmin contract to be the proxy contract's admin
    modifier ifAdmin() {
        //console.log("ifAdmin()... sender:", msg.sender);
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).addr1;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).addr1 = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).addr1;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).addr1 = _implementation;
    }

    // Admin interface //
    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    // 0x3659cfe6
    function upgradeTo(address _implementation) external ifAdmin {
        _setImplementation(_implementation);
    }

    // 0xf851a440
    function admin() external ifAdmin returns (address) {
        return _getAdmin();
    }

    // 0x5c60da1b
    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    //from Openzeppelin transparent upgradeable proxy
    function _delegate(address _implementation) internal virtual {
        //only use local variables here, no state variables!
        //(bool ok, ) = implementation.delegatecall(msg.data);
        //require(ok, "delegatecall failed");
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.

            // calldatacopy(t, f, s) - copy s bytes from calldata at position f to mem at position t
            // calldatasize() - size of call data in bytes
            // => copy all calldata to memory at position 0
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.

            // delegatecall(g, a, in, insize, out, outsize) -
            // - call contract at address a
            // - with input mem[in…(in+insize))
            // - providing g gas
            // - and output area mem[out…(out+outsize))
            // - returning 0 on error (eg. out of gas) and 1 on success
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
            // returndatasize() - size of the last returndata
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
            default {
                // return(p, s) - end execution, return data mem[p…(p+s))
                return(0, returndatasize())
            }
        }
    }
}

contract Dev {
    function selectors() external pure returns (bytes4, bytes4, bytes4) {
        return (Proxy.admin.selector, Proxy.implementation.selector, Proxy.upgradeTo.selector);
    }
}

contract ProxyAdmin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    //---------------== make view functions ... because ifAdmin in the proxy contract, those functions cannot be view functions...

    function getProxyAdmin(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.admin, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function getProxyImplementation(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.implementation, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    //---------------== Only owner can call
    // need to add "payable" because the proxy has both fallback() and receive()
    function changeProxyAdmin(address payable proxy, address admin) external onlyOwner {
        Proxy(proxy).changeAdmin(admin);
    }

    function upgrade(address payable proxy, address implementation) external onlyOwner {
        Proxy(proxy).upgradeTo(implementation);
    }
}

library StorageSlot {
    struct AddressSlot {
        address addr1;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        //to return the storage pointer r, located at <slot>
        assembly {
            r.slot := slot
        }
    }
}

contract TestSlot {
    bytes32 public constant slot = keccak256("TEST_SLOT");

    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(slot).addr1;
    }

    function writeSlot(address _addr) external {
        StorageSlot.getAddressSlot(slot).addr1 = _addr;
    }
}
