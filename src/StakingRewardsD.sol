// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
//import "@rari-capital/solmate/src/tokens/ERC20.sol";
/**
 * Similar to staking rewards contract.
 * Difference is that reward amount may vary at each second.
 */

contract StakingRewardsDiscrete {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    mapping(address => uint256) public staked;
    uint256 public totalStaked;

    uint256 private constant MULTIPLIER = 1e18;
    uint256 private rewardRatio;
    mapping(address => uint256) private rewardRatioOf;
    mapping(address => uint256) private earned;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    //updateRewardIndex
    function depositReward(uint256 reward) external {
        rewardToken.transferFrom(msg.sender, address(this), reward);
        rewardRatio += (reward * MULTIPLIER) / totalStaked;
    }

    //calculate since the last time his reward was updated
    function _calculateRewards(address account) private view returns (uint256) {
        uint256 stakedByAcct = staked[account];
        return (stakedByAcct * (rewardRatio - rewardRatioOf[account])) / MULTIPLIER;
    }

    function calculateRewardsEarned(address account) external view returns (uint256) {
        return earned[account] + _calculateRewards(account);
    }

    function _updateRewards(address account) private {
        earned[account] += _calculateRewards(account);
        rewardRatioOf[account] = rewardRatio;
    }

    function stake(uint256 amount) external {
        _updateRewards(msg.sender);

        staked[msg.sender] += amount;
        totalStaked += amount;

        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external {
        _updateRewards(msg.sender);

        staked[msg.sender] -= amount;
        totalStaked -= amount;

        stakingToken.transfer(msg.sender, amount);
    }

    function claim() external returns (uint256) {
        _updateRewards(msg.sender);

        uint256 reward = earned[msg.sender];
        if (reward > 0) {
            earned[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
        return reward;
    }
}
