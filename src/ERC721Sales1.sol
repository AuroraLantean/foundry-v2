// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
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

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//a simplified version of ERC721Sales.sol
contract ERC721Sales1 {
    IERC20 public immutable erc20token;

    address payable public owner;
    uint256 public priceA;
    uint256 public priceB;
    uint256 public priceC;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner == msg.sender, "unauthorized");
        _;
    }

    event Deposit(address indexed from, uint256 amount, uint256 gasleft);

    constructor(address erc20Addr) payable {
        require(erc20Addr != address(0), "should not be zero");
        require(erc20Addr.code.length != 0, "should be contracts");
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
        erc20token = IERC20(erc20Addr);
    }
    // Function to receive Ether. msg.data must be empty

    receive() external payable {
        //when msg.data is empty
        uint256 gasleftO = gasleft();
        console.log("receive", msg.sender, msg.value / 1e18, gasleftO);
        emit Deposit(msg.sender, msg.value, gasleftO);
    }

    fallback() external payable {
        console.log("fallback", msg.sender, msg.value);
        console.logBytes(msg.data);
        //must be external
        // send / transfer (forwards 2300 gas to this fallback function) call (forwards all of the gas)
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = payable(address(0));
        emit OwnershipTransferred(owner, address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = payable(newOwner);
    }

    function setPriceA(uint256 _priceA) external onlyOwner {
        priceA = _priceA;
    }

    function setPriceB(uint256 _priceB) external onlyOwner {
        priceB = _priceB;
    }

    function setpriceC(uint256 _priceC) external onlyOwner {
        priceC = _priceC;
    }

    function getNFTPrice(uint256 percentA, uint256 percentB) public view returns (uint256) {
        return (percentA * priceA) + (percentB * priceB) + priceC;
    }

    function deposit() public payable {}

    function buyNFTwETH(uint256 percentA, uint256 percentB) external payable {
        require(percentA <= 100, "percentA invalid");
        require(percentB <= 100, "percentB invalid");
        require(percentB + percentA == 100, "should be 100 percent");
        //percentA and percentB adds up to 100
        require(msg.sender != address(0), "invalid sender");
        require(msg.sender != address(this), "invalid sender");

        uint256 price = getNFTPrice(percentA, percentB);
        require(msg.value >= price, "invalid payment amount");
        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }

    function buyNFTwERC20(uint256 percentA, uint256 percentB, uint256 nftId) external {
        require(percentA <= 100, "percentA invalid");
        require(percentB <= 100, "percentB invalid");
        require(percentB + percentA == 100, "should be 100 percent");
        //percentA and percentB adds up to 100
        require(msg.sender != address(0), "invalid sender");
        require(msg.sender != address(this), "invalid sender");

        //require(ierc721Full.exists(nftId));

        uint256 price = getNFTPrice(percentA, percentB);
        erc20token.transferFrom(msg.sender, address(this), price);
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to transfer Ether from this contract to address from input
    // Note that "to" is declared as payable
    function withdraw(address payable _to, uint256 _amount) public {
        require(msg.sender == owner, "not owner");
        uint256 amount = _amount;
        if (_amount == 0) {
            amount = address(this).balance;
        }
        (bool success,) = _to.call{value: amount}("");
        require(success, "Failed to send Ether");

        //owner.transfer(_amount);
        //using memory variable msg is cheaper than state variable owner!
        //payable(msg.sender).transfer(_amount);
    }

    function sendViaCall(address payable _to) external payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        //console.log("sendViaCall() ... data:");
        //console.logBytes(data);
        require(sent, "Failed to send Ether");
    }
}
