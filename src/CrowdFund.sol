// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/* https://solidity-by-example.org/app/crowd-fund/
# User creates a campaign.
# Users can pledge, transferring their tokens to a campaign.
# After the campaign ends, campaign maker can claim the funds if total amount pledged is more than the campaign goal.
# Otherwise, campaign did not reach it's goal, users can withdraw their pledge.
*/

interface IERC20dup {
    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);
}

contract CrowdFund {
    event Launch(uint256 id, address indexed maker, uint256 goal, uint32 startAt, uint32 endAt);
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 id, address indexed caller, uint256 amount);

    struct Campaign {
        // Creator of campaign
        address maker;
        // Amount of tokens to raise
        uint256 goal;
        // Total amount pledged
        uint256 pledged;
        // Timestamp of start of campaign
        uint32 startAt;
        // Timestamp of end of campaign
        uint32 endAt;
        // True if goal was reached and maker has claimed the tokens.
        bool claimed;
    }

    IERC20dup public immutable token;
    // Total count of campaigns created.
    // It is also used to generate id for new campaigns.
    uint256 public count;
    // Mapping from id to Campaign
    mapping(uint256 => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20dup(_token);
    }

    function getTime() external view returns (uint32 blocktimestamp) {
        blocktimestamp = uint32(block.timestamp);
        //in JS: new Date().getTime()/1000
    }

    function launch(uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        count += 1;
        campaigns[count] =
            Campaign({maker: msg.sender, goal: _goal, pledged: 0, startAt: _startAt, endAt: _endAt, claimed: false});

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.maker == msg.sender, "not maker");
        require(block.timestamp < campaign.startAt, "started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended"); //this also checks if campaign does not exist

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended"); //this also checks if campaign does not exist

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.maker == msg.sender, "not maker");
        require(block.timestamp > campaign.endAt, "not ended"); //this also checks if campaign does not exist
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.maker, campaign.pledged);

        emit Claim(_id);
    }

    //if a campaign fails to reach its goal, then users can refund the tokens they have pledged
    function refund(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended"); //this also checks if campaign does not exist
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        uint256 bal = pledgedAmount[_id][msg.sender];
        require(bal > 0, "user's pledged amount should be > 0");
        pledgedAmount[_id][msg.sender] = 0; //prevents reentrancy
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
