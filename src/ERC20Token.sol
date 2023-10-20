// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import "solmate/tokens/ERC20.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //_mint, _burn

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance
import "@openzeppelin/contracts/security/Pausable.sol";

import "forge-std/console.sol";

contract ERC20Token is Ownable, ERC20, ERC20Burnable {
    //constructor() ERC20("GoldCoin", "GLDC") {}
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 9000000000 * 10 ** uint256(decimals()));
    }

    function mintToOwner() public onlyOwner {
        _mint(msg.sender, 90000000 * 10 ** uint256(decimals()));
    }

    function mint(address user, uint256 amount) public onlyOwner returns (bool) {
        _mint(user, amount);
        return true;
    }
}
//USDT, USDC use 6 dp !!! But DAI has 18!!

contract ERC20DP6 is ERC20Token {
    constructor(string memory name, string memory symbol) ERC20Token(name, symbol) {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

interface IERC20Receiver {
    /**
     * @dev Whenever an {IERC20} `tokenId` token is transferred to this contract via {IERC20-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC20Receiver.tokenReceived.selector`.
     */
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4);
}

contract ERC20Receiver {
    using SafeERC20 for IERC20;

    event TokenReceived(address indexed from, uint256 indexed amount, bytes data);

    bytes4 private constant _ERC20_RECEIVED = 0x8943ec02;
    // Equals to `bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")))`
    // OR IERC20Receiver.tokenReceived.selector

    /**
     * The selector can be obtained in Solidity with `IERC20Receiver.tokenReceived.selector`.
     */
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4) {
        //console.log("tokenReceived");
        emit TokenReceived(from, amount, data);
        return _ERC20_RECEIVED;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit(address erc20Addr, uint256 amount) public {
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), amount);
    }

    function safeDeposit(address erc20Addr, uint256 amount) public {
        IERC20(erc20Addr).safeTransferFrom(msg.sender, address(this), amount);
    }

    function transfer(address erc20Addr, address to, uint256 amount) public {
        IERC20(erc20Addr).transfer(to, amount);
    }

    function safeTransfer(address erc20Addr, address to, uint256 amount) public {
        IERC20(erc20Addr).safeTransfer(to, amount);
    }

    function safeApprove(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).safeApprove(spender, amount);
    }

    function forceApprove(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).forceApprove(spender, amount);
    }

    function safeIncreaseAllowance(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).safeIncreaseAllowance(spender, amount);
    }

    function safeDecreaseAllowance(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).safeDecreaseAllowance(spender, amount);
    }

    function safePermit(
        address erc20Addr,
        IERC20Permit token,
        address tokenOwner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        //IERC20(erc20Addr).safePermit(token, tokenOwner, spender, value, deadline, v, r, s);
    }

    function executeTxn(address _ctrt, uint256 _value, bytes calldata _data) public {
        //console.log("executeTxn()...", _data, msg.value);
        (bool success, /*bytes memory _databk*/ ) = _ctrt.call{value: _value}(_data);
        //console.logBytes(_databk);
        require(success, "tx failed");
    }

    //be careful of function signature typo, and arg types
    function makeCalldata(string memory _funcSig, address to, uint256 amount) public pure returns (bytes memory) {
        //_funcSig example: "transfer(address,uint256)"
        return abi.encodeWithSignature(_funcSig, to, amount);
    }

    function makeBytes() public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")));
    }

    function makeBytes2() public pure returns (bytes4) {
        return IERC20Receiver.tokenReceived.selector;
    }

    receive() external payable {
        revert("should not send any ether directly");
    }
}
