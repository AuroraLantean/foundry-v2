// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //0.8.10 for Aave 1.19.1

import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol"; // executeOperation(), ADDRESS_PROVIDER(), POOL()
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
//import "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import {SafeMath} from '../../dependencies/openzeppelin/contracts/SafeMath.sol';

interface IDex {
    function depositUSDC(uint256 _amount) external;
    function depositDAI(uint256 _amount) external;
    function swapUsdcDai() external;
    function swapDaiUsdc() external;
}

contract FlashloanClientAave is FlashLoanSimpleReceiverBase {
    address payable owner;
    //https://staging.aave.com/faucet/?marketName=proto_sepolia_v3
    address public immutable daiAddr = 0x68194a729C2450ad26072b3D33ADaCbcef39D574;
    address public immutable usdcAddr = 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f;

    IERC20 public dai;
    IERC20 public usdc;
    IDex public dex;
    uint256 public loanAmount;

    //Get _addrProvider from https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses ... Sepolia
    constructor(address _addrProvider) FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addrProvider)) {
        owner = payable(msg.sender);
        loanAmount = 1000000000; // 1000 USDC
        address dexAddr = 0x1fe62386FF102eF40F61b9d9320d2CCA220d00D8;
        dai = IERC20(daiAddr);
        usdc = IERC20(usdcAddr);
        dex = IDex(dexAddr);
    }

    /* This function is called after your contract has received the flashloan amount.
    * @dev MUST APPROVE the pool to pull flashloan amount + fee
    * @param asset The address of the flash-borrowed asset
    * @param amount The amount of the flash-borrowed asset
    * @param fee The fee of the flash-borrowed asset
    * @param initiator: the flashloan initiator
    * @param params: The byte-encoded params passed when initiating the flashloan
    * @return True if the execution of the operation succeeds, false otherwise
     */

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 fee,
        address, //initiator,
        bytes calldata //params
    ) external override returns (bool) {
        // After getting the fund...

        // Arbirtage operation
        dex.depositUSDC(loanAmount); // 1000 USDC
        dex.swapUsdcDai();
        dex.depositDAI(dai.balanceOf(address(this)));
        dex.swapDaiUsdc();

        // This contract MUST have enough USDC to pay fee!
        uint256 amountOwed = amount + fee;

        //POOL has been initiated in your dependency FlashLoanSimpleReceiverBase
        IERC20(asset).approve(address(POOL), amountOwed);
        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public {
        /**
         * @aave/core-v3/contracts/interfaces/IPool.sol
         * @notice Allows smartcontracts to access the liquidity of the pool within one transaction,
         * as long as the amount taken plus a fee is returned.
         * @dev IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept
         * into consideration. For further details please visit https://docs.aave.com/developers/
         * @param receiverAddress The address of the contract receiving the funds, implementing IFlashLoanSimpleReceiver interface
         * @param asset The address of the asset being flash-borrowed
         * @param amount The amount of the asset being flash-borrowed
         * @param params Variadic packed params to pass to the receiver as extra information
         * @param referralCode The code used to register the integrator originating the operation, for potential rewards.
         *   0 if the action is executed directly by the user, without any middle-man
         *  address receiverAddress,
         *  address asset = _token
         * uint256 amount,
         * bytes calldata params,
         * uint16 referralCode
         */
        address receiverAddress = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(receiverAddress, _token, _amount, params, referralCode);
    }

    function approveUSDC(uint256 _amount) external onlyOwner returns (bool) {
        return usdc.approve(address(dex), _amount);
    }

    function allowanceUSDC() external view returns (uint256) {
        return usdc.allowance(address(this), address(dex));
    }

    function approveDAI(uint256 _amount) external onlyOwner returns (bool) {
        return dai.approve(address(dex), _amount);
    }

    function allowanceDAI() external view returns (uint256) {
        return dai.allowance(address(this), address(dex));
    }

    function getTokenBalc(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdrawToken(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    receive() external payable {}

    function setLoanAmount(uint256 amount) external onlyOwner {
        loanAmount = amount;
    }

    function setAddr(uint8 choice, address addr) external onlyOwner {
        if (choice == 0) {
            dai = IERC20(addr);
        } else if (choice == 1) {
            usdc = IERC20(addr);
        } else {
            dex = IDex(addr);
        }
    }
}
