// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
//https://solidity-by-example.org/app/dutch-auction/
/**
 * Seller of NFT deploys this contract setting a starting price for the NFT.
 *     Auction lasts for 7 days.
 *     Price of NFT decreases over time.
 *     Participants can buy by depositing ETH greater than the current price computed by the smart contract.
 *     Auction ends when a buyer buys the NFT.
 */

interface IERC721dup {
    function transferFrom(address _from, address _to, uint256 _nftId) external;
}

contract AuctionDutch {
    uint256 public constant DURATION = 7 days;

    IERC721dup public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;

    constructor(uint256 _startingPrice, uint256 _discountRate, address _nft, uint256 _nftId) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;

        //USE INPUTS, NOT THE STATE VARIABLES!!! BECAUSE INSIDE THE CONSTRUCTOR, you cannot read the state variables!!!
        require(_startingPrice >= _discountRate * DURATION, "starting price < min");

        nft = IERC721dup(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    error FailedInnerCall();

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        (bool success,) = seller.call{value: address(this).balance}("");
        if (!success) {
            revert("call{value} failed");
        }
        //selfdestruct(seller);// sendValue
    }
}
