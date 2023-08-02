// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityClientAave {
    address payable owner;

    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;
    IERC20 public token;

    constructor(address _addressProvider) {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(_addressProvider);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
        owner = payable(msg.sender);
        address tokenAddr = 0x8a0E31de20651fe58A369fD6f76c21A8FF7f8d42;
        token = IERC20(tokenAddr);
    }

    function setToken(address addr) external onlyOwner {
        token = IERC20(addr);
    }

    function supplyLiquidity(address _tokenAddress, uint256 _amount) external {
        address onBehalfOf = address(this);
        uint16 referralCode = 0;
        POOL.supply(_tokenAddress, _amount, onBehalfOf, referralCode); //from Aave IPool.sol
    }

    //* @param amount: Send the value type(uint256).max in order to withdraw the whole aToken balance
    function withdrawlLiquidity(address _tokenAddress, uint256 _amount) external returns (uint256) {
        address to = address(this);
        return POOL.withdraw(_tokenAddress, _amount, to);
    }
    /**
     * @notice Returns the user account data across all the reserves
     * @return totalCollateralBase The total collateral of the user in the base currency used by the price feed
     * @return totalDebtBase The total debt of the user in the base currency used by the price feed
     * @return availableBorrowsBase The borrowing power left of the user in the base currency used by the price feed
     * @return currentLiquidationThreshold The liquidation threshold of the user
     * @return ltv The loan to value of The user
     * @return healthFactor The current health factor of the user
     */

    function getUserAccountData(address _userAddress)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return POOL.getUserAccountData(_userAddress);
    }

    function approveToken(uint256 _amount, address _poolAddr) external returns (bool) {
        return token.approve(_poolAddr, _amount);
    }

    function allowanceToken(address _poolAddr) external view returns (uint256) {
        return token.allowance(address(this), _poolAddr);
    }

    function getTokenBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    receive() external payable {}
}
