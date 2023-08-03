// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Submitted for verification at Etherscan.io on 2020-09-04
 * https://goerli.etherscan.io/address/0x326C977E6efc84E512bB9C30f76E30c160eD06FB#code
 *
 * https://github.com/smartcontractkit/LinkToken/tree/master/contracts/v0.4
 */
interface IERC677 {
    function allowance(address owner, address spender) external returns (bool success);
    function approve(address spender, uint256 value) external returns (bool success);
    function balanceOf(address owner) external returns (uint256 balance);
    function decimals() external returns (uint8 decimalPlaces);
    function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
    function increaseApproval(address spender, uint256 subtractedValue) external;
    function name() external returns (string memory tokenName);
    function symbol() external returns (string memory tokenSymbol);
    function totalSupply() external returns (uint256 totalTokensIssued);
    function transfer(address to, uint256 value) external returns (bool success);
    function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
}
// File: https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.4/interfaces/ERC677Receiver.sol

interface ERC677Receiver {
    function onTokenTransfer(address _sender, uint256 _value, bytes memory _data) external;
}

// File: https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.4/interfaces/ERC20Basic.sol

// File: https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.4/interfaces/ERC20.sol

// File: https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.4/interfaces/ERC677.sol

/*contract ERC677 is ERC20 {
    function transferAndCall(address to, uint256 value, bytes data) returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}*/

// File: https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.4/ERC677Token.sol
