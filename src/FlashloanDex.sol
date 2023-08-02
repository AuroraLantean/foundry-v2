// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashloanDex {
    address payable public owner;

    // https://staging.aave.com/faucet/?marketName=proto_sepolia_v3
    address public immutable daiAddress = 0x68194a729C2450ad26072b3D33ADaCbcef39D574;
    address public immutable usdcAddress = 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f;

    IERC20 private dai;
    IERC20 private usdc;

    // exchange rate indexes
    uint256 dexARate = 90;
    uint256 dexBRate = 100;

    // keeps track of individuals' dai balances
    mapping(address => uint256) public daiBalances;

    // keeps track of individuals' USDC balances
    mapping(address => uint256) public usdcBalances;

    constructor() {
        owner = payable(msg.sender);
        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
    }

    function depositUSDC(uint256 _amount) external {
        usdcBalances[msg.sender] += _amount;
        uint256 allowance = usdc.allowance(msg.sender, address(this));
        require(allowance >= _amount, "USDC allowance not enough");
        usdc.transferFrom(msg.sender, address(this), _amount);
    }

    function depositDAI(uint256 _amount) external {
        daiBalances[msg.sender] += _amount;
        uint256 allowance = dai.allowance(msg.sender, address(this));
        require(allowance >= _amount, "DAI allowance not enough");
        dai.transferFrom(msg.sender, address(this), _amount);
    }

    function swapUsdcDai() external {
        uint256 daiToReceive = ((usdcBalances[msg.sender] / dexARate) * 100) * (10 ** 12);
        usdcBalances[msg.sender] = 0;
        dai.transfer(msg.sender, daiToReceive);
    }

    function swapDaiUsdc() external {
        uint256 usdcToReceive = ((daiBalances[msg.sender] * dexBRate) / 100) / (10 ** 12);
        daiBalances[msg.sender] = 0;
        usdc.transfer(msg.sender, usdcToReceive);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    receive() external payable {}
}
