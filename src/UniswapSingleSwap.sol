// SPDX-License-Identifier: MIT
pragma solidity >0.7.6;
pragma abicoder v2;

//https://docs.uniswap.org/contracts/v3/guides/swaps/single-swaps
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
//import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';//using older OpenZeppelin! Bad for our compilation. Also it assumes EOA initiate the txn, not good for our contract scenario, and not easy for a demo as it needs extra code and EOA approval
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapSingleSwap {
    address payable owner;
    //https://docs.uniswap.org/contracts/v3/reference/deployments
    address public WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    // Goerli network
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

    IERC20 public token = IERC20(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //https://docs.chain.link/resources/link-token-contracts
    address public usdcAddr = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F; //https://developers.circle.com/developer/docs/usdc-on-testnet
    address public usdtAddr;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public poolFee = 3000;

    // msg.sender must approve this contract
    constructor() {
        owner = payable(msg.sender);
    }
    /*constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }// passing in the swap router for simplicity. More advanced contracts will show how to inherit the swap router safely.
    */

    function setAddr(uint8 choice, address addr) external onlyOwner {
        if (choice == 0) {
            token = IERC20(addr);
        } else if (choice == 1) {
            usdcAddr = addr;
        } else {
            usdtAddr = addr;
        }
    }

    function setNum(uint8 choice, uint256 num) external onlyOwner {
        if (choice == 0) {
            poolFee = uint24(num);
        }
    }

    /// @notice swapExactInputSingle swaps a fixed amount of Token for a maximum possible amount of WETH9
    /// using the Token/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its Token for this function to succeed.
    /// @param amountIn The exact amount of Token that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.

    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        token.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // sqrtPriceLimitx96: upper limit of the slippage. Set it to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(token),
            tokenOut: WETH,
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp, // + 60*3 for 3 minutes
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of Token for a fixed amount of WETH.
    /// @dev The calling address must approve this contract to spend its Token for this function to succeed. As the amount of input Token is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of WETH9 to receive from the swap.
    /// @param amountInMaximum The amount of Token we are willing to spend to receive the specified amount of WETH9.
    /// @return amountIn The amount of Token actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        token.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: address(token),
            tokenOut: WETH,
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: amountOut,
            amountInMaximum: amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountIn = swapRouter.exactOutputSingle(params);

        // For exact output swaps, the amountInMaximum may not have all been spent due to slippage
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            token.approve(address(swapRouter), 0);
            token.transfer(address(this), amountInMaximum - amountIn);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    receive() external payable {}
}
