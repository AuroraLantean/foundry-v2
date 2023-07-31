// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
//https://solidity-by-example.org/sending-ether/

contract Callee {
    string public mesg;
    uint256 public num;

    receive() external payable {
        console.log("receive():", msg.sender, msg.value);
        mesg = "receive";
    }

    //if this fallback does not exist, incoming call with data will fail!
    fallback() external payable {
        console.log("fallback():", msg.sender, msg.value);
        mesg = "fallback";
    }

    function foo(string memory _mesg, uint256 _num) public payable returns (uint256) {
        console.log("foo():", msg.sender, msg.value, _mesg);
        mesg = _mesg;
        num = _num;
        return _num + 1;
    }
}

contract Caller {
    bytes public data;
    bool public success;

    // Caller Ctrt does not know destination function argument
    function callFoo(address _addr, string calldata _mesg, uint256 _num) public payable {
        console.log("callFoo()...", _mesg, msg.value);
        (bool _success, bytes memory _data) =
            _addr.call{value: msg.value}(abi.encodeWithSignature("foo(string,uint256)", _mesg, _num)); //MUST have no space, and replace uint by uint256 in function signature! Remove "gas: 5000" as it is not enough!
        console.log("callFoo() result:", _success);
        console.logBytes(_data);
        require(_success, "callFoo failed");
        success = _success;
        data = _data;
    }

    // Calling a function that does not exist triggers the fallback function.
    function callFuncNotExisting(address _addr) public payable {
        console.log("callFuncNotExisting(), msg.value:", msg.value);
        (bool _success, bytes memory _data) = _addr.call{value: msg.value}(abi.encodeWithSignature("doesNotExist()"));
        console.log("callFuncNotExisting() result:", _success, msg.value);
        console.logBytes(_data);
        success = _success;
        data = _data;
    }
}
