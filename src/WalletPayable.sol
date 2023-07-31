// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
//https://solidity-by-example.org/fallback/
/*
    Which function is called, fallback() or receive()?

           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */

contract WalletPayable {
    address payable public owner; //payable should be right after the "address"
    address public sender;

    event Deposit(address indexed from, uint256 amount, uint256 gasleft);
    event LogInput(string func, address sender, uint256 value, bytes data);

    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }

    function deposit() public payable {}

    receive() external payable {
        //when msg.data is empty
        uint256 gasleftO = gasleft();
        console.log("receive", msg.sender, msg.value / 1e18, gasleftO);
        sender = msg.sender;
        emit Deposit(msg.sender, msg.value, gasleftO);
    }

    fallback() external payable {
        console.log("fallback", msg.sender, msg.value);
        console.logBytes(msg.data);
        sender = msg.sender;
        //must be external
        // send / transfer (forwards 2300 gas to this fallback function) call (forwards all of the gas)
    }

    // send ETH with invoking this function will throw an error since this function is not payable.
    function notPayable() public {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owner, "not owner");
        owner = payable(newOwner);
    }
    // Function to withdraw all Ether from this contract.

    function withdrawAll() public {
        require(msg.sender == owner, "not owner");
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function withdraw(address payable _to, uint256 _amount) public {
        require(msg.sender == owner, "not owner");
        // Note that "to" is declared as payable
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");

        //owner.transfer(_amount);
        //using memory variable msg is cheaper than state variable owner!
        //payable(msg.sender).transfer(_amount);
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

//-------------------------==
//fallback can optionally take bytes for input and output

// TestFallbackInputOutput -> FallbackInputOutput -> Counter
contract FallbackInputOutput {
    address immutable target;

    constructor(address _target) {
        target = _target;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        (bool ok, bytes memory res) = target.call{value: msg.value}(data);
        require(ok, "call failed");
        return res;
    }
}

contract Counter {
    uint256 public count;

    function get() external view returns (uint256) {
        return count;
    }

    function inc() external returns (uint256) {
        count += 1;
        return count;
    }
}

contract TestFallbackInputOutput {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);
        require(ok, "call failed");
        emit Log(res);
    }

    function getTestData() external pure returns (bytes memory, bytes memory) {
        return (abi.encodeCall(Counter.get, ()), abi.encodeCall(Counter.inc, ()));
    }
}
