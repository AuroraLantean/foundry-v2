// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

//import "solmate/tokens/ERC20.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //_mint, _burn
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance
import "@openzeppelin/contracts/security/Pausable.sol";

interface IERC20AndPermit is IERC20, IERC20Permit {}

/**
 * by presenting a message signed by the token owner, the token owner doesn't need to send a transaction, and thus is not required to hold Ether at all.
 *
 *   function permit(
 *         address owner,
 *         address spender,
 *         uint256 value,
 *         uint256 deadline,
 *         uint8 v,
 *         bytes32 r,
 *         bytes32 s
 *     ) external;
 *   function nonces(address owner) external view returns (uint256);
 *   function DOMAIN_SEPARATOR() external view returns (bytes32);
 */
contract ERC20PermitOz is Ownable, ERC20, ERC20Burnable, ERC20Permit {
    //constructor() ERC20("GoldCoin", "GLDC") {}
    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
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

interface IERC20Receiver {
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4);
}

contract ERC20PermitStaking {
    using SafeERC20 for IERC20;

    ERC20PermitOz public immutable token;
    address public owner;

    constructor(address _token) {
        token = ERC20PermitOz(_token);
        owner = msg.sender;
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
    }
    /**
     * to avoid token owners calling ERC20 approve()
     * anyone can call ERC20Permit/permit(...), then their contract can call transferFrom() without approvals.
     * From OZ/ERC20Permit.sol:
     *     function permit(
     *     address tokenOwner,
     *     address spender,
     *     uint256 value,
     *     uint256 deadline,
     *     uint8 v,
     *     bytes32 r,
     *     bytes32 s)
     */

    function depositWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        token.transferFrom(msg.sender, address(this), amount);
    }
    /**
     * to transfer some amount + fee(given to msg.sender)
     *   For OZ/ERC20Permit.sol
     * # owner = tokenOwner
     * # spender = address(this)
     * # value = amount + fee
     * # deadline: the deadline for the permit signature v, r, and s to be valid
     */

    function send(
        address tok,
        address tokenOwner,
        address receiver,
        uint256 amount,
        uint256 fee,
        uint256 deadline,
        // Permit signature
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20AndPermit(tok).permit(tokenOwner, address(this), amount + fee, deadline, v, r, s);
        // Send amount to receiver
        IERC20AndPermit(tok).transferFrom(tokenOwner, receiver, amount);
        // Take fee - send fee to msg.sender
        IERC20AndPermit(tok).transferFrom(tokenOwner, msg.sender, fee);
    }

    //-------------------==
    // function safeDeposit(address erc20Addr, uint256 amount) public {
    //     IERC20(erc20Addr).safeTransferFrom(msg.sender, address(this), amount);
    // }

    function transfer(address erc20Addr, address to, uint256 amount) public {
        IERC20(erc20Addr).transfer(to, amount);
    }

    // function safeTransfer(address erc20Addr, address to, uint256 amount) public {
    //     IERC20(erc20Addr).safeTransfer(to, amount);
    // }

    //---------------------==
    event TokenReceived(address indexed from, uint256 indexed amount, bytes data);

    bytes4 private constant _ERC20_RECEIVED = 0x8943ec02;
    // Equals to `bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")))`
    // OR IERC20Receiver.tokenReceived.selector

    /**
     * The selector can be obtained in Solidity with `IERC20Receiver.tokenReceived.selector`.
     */
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4) {
        console.log("tokenReceived");
        emit TokenReceived(from, amount, data);
        return _ERC20_RECEIVED;
    }

    function executeTxn(address _ctrt, uint256 _value, bytes calldata _data) public {
        //console.log("executeTxn()...", _data, msg.value);
        (bool success, bytes memory _databk) = _ctrt.call{value: _value}(_data);
        console.logBytes(_databk);
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
