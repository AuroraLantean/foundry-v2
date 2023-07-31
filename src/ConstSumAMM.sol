// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * Constant sum AMM X + Y = K
 * Tokens trade one to one.
 */
contract ConstSumAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0; //token0
    uint256 public reserve1; //token1

    uint256 public totalShares;
    mapping(address => uint256) public userShares;

    constructor(address _token0, address _token1) {
        // NOTE: This contract assumes that token0 and token1
        // both have same decimals
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 _amount) private {
        userShares[_to] += _amount;
        totalShares += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        userShares[_from] -= _amount;
        totalShares -= _amount;
    }

    function _update(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");
        require(_amountIn > 0, "amount in = 0");

        bool isToken0 = _tokenIn == address(token0);

        (IERC20 tokenIn, IERC20 tokenOut, uint256 resIn, uint256 resOut) =
            isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        //transfer tokens in
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint256 amountIn = tokenIn.balanceOf(address(this)) - resIn;

        // calculate amountOut (including fees)
        // dx = amountIn, dy = amountOut:
        // X + Y = K => dy == p * dx
        // if fees = 0, dy == dx
        // if 0.3% fee, dy = 99.7% of amountIn
        amountOut = (amountIn * 997) / 1000;

        // update reserve0 and reserve1
        (uint256 res0, uint256 res1) =
            isToken0 ? (resIn + amountIn, resOut - amountOut) : (resOut - amountOut, resIn + amountIn);
        _update(res0, res1);

        // transfer tokens out
        tokenOut.transfer(msg.sender, amountOut);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        uint256 d0 = bal0 - reserve0; //d means delta or difference
        uint256 d1 = bal1 - reserve1;

        /* see reference Vault.sol
        a = token amount deposited
        B = balance of token before deposit(total liquidity)
        T = total shares
        s = shares to mint

        s should be proportional to increase from L to L + a
        (T + s) / T = (a + B) / B
        then we get: s = a * T / B
        but if T = 0, s = a 
        */
        if (totalShares > 0) {
            shares = ((d0 + d1) * totalShares) / (reserve0 + reserve1);
        } else {
            shares = d0 + d1;
        }

        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(bal0, bal1);
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 d0, uint256 d1) {
        /*
        a = token amount to withdraw
        B = balance of token before withdraw(total liquidity)
        T = total shares
        s = shares to burn
        
        s is proportional to the decrease of the vault token balance:
        (T - s) / T = (B - a) / B 

        a = s * B / T
          = (reserve0 + reserve1) * s / T
        */
        d0 = (reserve0 * _shares) / totalShares;
        d1 = (reserve1 * _shares) / totalShares;

        _burn(msg.sender, _shares);
        _update(reserve0 - d0, reserve1 - d1);

        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}
