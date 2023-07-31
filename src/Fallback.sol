// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/**
 * fallback is a special function that is executed either when
 * # a function that does not exist is called or
 * # Ether is sent directly to a contract but receive() does not exist or msg.data is not empty
 *
 * fallback has a 2300 gas limit when called by transfer or send.
 * fallback can optionally take bytes for input and output
 */

contract FallbackBasic {
    event Log(string func, uint256 gas);

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        emit Log("fallback", gasleft());
    }

    // Receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}

//------------------==
// Departure -> FallbackIO -> Dest
contract Dest {
    uint256 public count;

    function get() external view returns (uint256) {
        console.log("Dest/get()...");
        return count;
    }

    function inc() external returns (uint256) {
        console.log("Dest/inc()...");
        count += 1;
        return count;
    }
}

contract FallbackIO {
    address immutable dest;

    constructor(address _dest) {
        dest = _dest;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        console.log("FallbackIO/fallback()...");
        (bool ok, bytes memory res) = dest.call{value: msg.value}(data);
        require(ok, "call failed");
        return res;
    }

    //receive() external payable returns(bytes memory) {} ... receive() cannot return values! Use fallback()
}

contract Departure {
    event Log(bytes res);

    function depart(address _fallbackio, bytes calldata data) external returns (uint256 out) {
        console.log("Departure/depart()...");
        (bool ok, bytes memory res) = _fallbackio.call(data);
        require(ok, "call failed");
        console.log("Departure/depart(): res...");
        console.logBytes(res);
        out = uint256(bytes32(res));
        emit Log(res);
    }

    function getCallData() external pure returns (bytes memory, bytes memory) {
        return (abi.encodeCall(Dest.get, ()), abi.encodeCall(Dest.inc, ()));
    }
}
