// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Weth is ERC20, ERC20Burnable {
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH") {}

    receive() external payable {
        //when msg.data is empty
        console.log("receive", msg.sender, msg.value);
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        //using memory variable msg is cheaper than state variable owner!

        //PRECOMPILE::ecrecover
        //payable(msg.sender).transfer(_amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send Ether");
        emit Withdraw(msg.sender, _amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
