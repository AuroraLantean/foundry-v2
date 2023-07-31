// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/**
 * Transparent upgradeable proxy pattern
 * # MUST have the same slot data as the proxy contract: Storage for implementation and admin
 * # read data...
 *
 * Separate user and admin interfaces
 * Proxy admin
 *
 * Shortcoming: cannot return data correctly
 */
contract CounterV1 {
    //MUST have the same slot data(storage layout) as the proxy contract
    address public implementation; //MUST add this
    address public admin; //MUST add this
    uint256 public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 is CounterV1{
    //MUST have the same slot data as the proxy contract
    uint256 public owner;
    mapping(address => uint256) shareHolder; //New variables!
    bytes32[] examples; // dynamic array => USE PUSH

    function dec() external {
        count -= 1;
    }
}

contract ProxyBuggy {
    address public implementation;
    address public admin;
    uint256 public count; //MUST ADD FROM DEST CONTRACT!!!

    constructor() {
        admin = msg.sender;
    }

    function _delegate() private {
        (bool ok,) = implementation.delegatecall(msg.data);
        require(ok, "delegatecall failed");
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
    }
}

contract ProxyFixed {
    address public implementation;
    address public admin;
    //uint public count;//from dest contract

    constructor() {
        admin = msg.sender;
    }

    fallback() external payable {
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
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
