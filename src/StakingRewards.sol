// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * a stripped down version of Synthetix StakingRewards.sol
 * https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol
 */
contract StakingRewards is Ownable {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    // Duration of rewards to be paid out (in seconds)
    uint256 public duration;
    // Timestamp of when the rewards finish
    uint256 public finishAt;
    // Minimum of last updated time and reward finish time
    uint256 public updatedAt;
    // Reward to be paid out per second
    uint256 public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total staked)
    uint256 public rewardPerTokenStored; //scaled up by 1e18
    // User address => userRewardPerTokenPaid, scaled up by 1e18
    mapping(address => uint256) public rewardPerTokenUser;
    // User address => rewards earned by user, to be claimed
    mapping(address => uint256) public rewards;

    // TotalSupply of staked tokens
    uint256 public totalStaked;
    // User address => staked amount
    mapping(address => uint256) public staked;

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardToken);
    }

    // to track rewardPerToken and rewardPerTokenUser
    // used in stake(), withdraw(), claimReward(), and setRewardRateAndFinishedAt(address(0))
    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        //when the contract owner calls setRewardRateAndFinishedAt(), _account will be address(0), because we do not need to calculate owner's reward
        if (_account != address(0)) {
            rewards[_account] = getEarned(_account);
            rewardPerTokenUser[_account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256 lastTime) {
        lastTime = _min(finishAt, block.timestamp);
    }

    //reward per staked token. scaled up by 1e18
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        //totalStaked > 0
        return rewardPerTokenStored + (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) / totalStaked;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    // aka earned()
    function getEarned(address _account) public view returns (uint256 earned) {
        console.log("getEarned()");
        //console.log(staked[_account], rewardPerToken());
        //console.log(rewardPerTokenUser[_account], rewards[_account]);
        earned = ((staked[_account] * (rewardPerToken() - rewardPerTokenUser[_account])) / 1e18) + rewards[_account];
    } //rewardPerToken() and rewardPerTokenUser have been scaled up to 1e18, but we should multiply before divide it by 1e18

    //getReward
    function claimReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0; //reset user reward to 0 first!
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    // set rewardRate + finishedAt... aka notifyRewardAmount
    function setRewardRateAndFinishedAt(uint256 _rwAmount) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= finishAt) {
            //reward duration has expired, or not started yet
            rewardRate = _rwAmount / duration;
        } else {
            //still in reward duration
            uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_rwAmount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "not enough reward tokens to pay reward amount"
        );
        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}
