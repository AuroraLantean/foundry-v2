// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@rari-capital/solmate/src/tokens/ERC20.sol";

/**
 * This vault focuses on the math of calculating shares to mint on deposit and the amount of token to withdraw.
 *
 * How the contract works
 * # Some amount of shares are minted when an user deposits.
 * # The DeFi protocol would use the users' deposits to generate yield (somehow).
 * # User burn shares to withdraw his tokens + yield.
 */
contract Vault {
    IERC20 public immutable token;

    uint256 public totalShares;
    mapping(address => uint256) public userShares;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint256 _shares) private {
        totalShares += _shares;
        userShares[_to] += _shares;
    }

    function _burn(address _from, uint256 _shares) private {
        totalShares -= _shares;
        userShares[_from] -= _shares;
    }

    function deposit(uint256 _amount) external {
        /*
        a = token amount deposited
        B = balance of token before deposit
        T = total shares
        s = shares to mint

        s is proportional to the increase of the vault token balance:
        (T + s) / T = (a + B) / B 
        then we get: s = a * T / B
        but if T = 0, s = a 
        */
        uint256 shares;
        if (totalShares > 0) {
            shares = (_amount * totalShares) / token.balanceOf(address(this)); //Make sure do MULTIPLICATION BEFORE DEVIDING!
        } else {
            shares = _amount;
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _shares) external {
        /*
        a = token amount to withdraw
        B = balance of token before withdraw
        T = total shares
        s = shares to burn
        
        s is proportional to the decrease of the vault token balance:
        (T - s) / T = (B - a) / B 

        a = s * B / T
        */
        uint256 amount = (_shares * token.balanceOf(address(this))) / totalShares;
        _burn(msg.sender, _shares);
        if (amount > 0) {
            token.transfer(msg.sender, amount);
        }
    }
}
