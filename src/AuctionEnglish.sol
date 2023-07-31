// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/**
 * https://solidity-by-example.org/app/english-auction/
 * Action:
 * # Seller of NFT deploys this contract.
 * # Auction lasts for 7 days.
 * # Participants can bid by depositing ETH greater than the current highest bidder.
 * # All bidders can withdraw their bid if it is not the current highest bid.
 *
 * After the auction:
 * # Highest bidder becomes the new owner of NFT.
 * # The seller receives the highest bid of ETH.
 */

interface IERC721dup {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address, address, uint256) external;
}

contract AuctionEnglish {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    IERC721dup public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public startAt;
    uint256 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public totalLostBids;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid) {
        nft = IERC721dup(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        require(!started, "started");
        require(msg.sender == seller, "not seller");
        startAt = block.timestamp;
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + 7 days;

        emit Start();
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        if (highestBidder != address(0)) {
            totalLostBids[highestBidder] += highestBid;
            //to add all the ETH previously highest bidder has sent to this contract
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 bal = totalLostBids[msg.sender];
        totalLostBids[msg.sender] = 0; //prevent reentrancy!
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    //for anyone to call in case the seller does not want to invoke this function when the auction ends
    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");
        console.log("check1");
        ended = true;
        if (highestBidder != address(0)) {
            console.log("check2a");
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            console.log("check3a");
            (bool ok,) = seller.call{value: highestBid}("");
            require(ok, "Failed to send Ether");
            //seller.transfer(highestBid);//Foundry Error: PRECOMPILE::ecrecover{value: 30}()
            console.log("check4a");
        } else {
            //if no one bits on this auction
            console.log("check2b");
            nft.safeTransferFrom(address(this), seller, nftId);
        }
        console.log("check5");

        emit End(highestBidder, highestBid);
    }
}
