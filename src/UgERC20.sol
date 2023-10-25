// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol"; //_mint, _burn

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; //owner(), onlyOwner, renounceOwnership, transferOwnership,

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol"; //paused, whenNotPaused, whenPaused, _pause, _unpause

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol"; //burn, burnFrom
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance

import "forge-std/console.sol";

contract ERC20UToken is OwnableUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable {
    uint256 public num1;

    function initialize(string memory name, string memory symbol) public initializer {
        //console.log("ERC20Token initialize msg.sender:", msg.sender);
        __Ownable_init_unchained(msg.sender);
        __ERC20_init_unchained(name, symbol);
        num1 = 5;
        //_mint(msg.sender, initialSupply);
    }

    constructor() {
        //to disable re-initialization. See Initializable.sol
        _disableInitializers(); //impl.getInitialized(): 255
    }

    function mint(address user, uint256 amount) public onlyOwner returns (bool) {
        _mint(user, amount);
        return true;
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferInternal(address from, address to, uint256 value) public {
        _transfer(from, to, value);
    }

    function approveInternal(address owner1, address spender, uint256 value) public {
        _approve(owner1, spender, value);
    }
}

//USE inheritance to MAKE SURE the state variables are the same!
contract ERC20UTokenV2 is ERC20UToken {
    uint256 public num2;

    function setNum2(uint256 _b) external {
        num2 = _b;
    }
}

contract ERC20UTokenHack is ERC20UToken {
    //uint256 public num2;
    function attack(uint256 _b) external {
        num1 = _b;
    }
}

//------------------------------==
contract ERC20UStaking is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;
    //using SafeERC20Upgradeable for IERC20Upgradeable;
    using Address for address;

    uint256 public num1;
    address public rwTokenAddr;
    mapping(address => uint256) public staked;

    function initialize(address _rwTokenAddr) external initializer {
        //console.log("ERC20Staking initialize msg.sender:", msg.sender);
        require(_rwTokenAddr != address(0), "invalid token address");
        require(_rwTokenAddr.code.length != 0, "should be a contract");
        rwTokenAddr = _rwTokenAddr;
        num1 = 11;
        __Ownable_init(msg.sender);
        __Pausable_init();
    }

    constructor() {
        //to disable re-initialization. See Initializable.sol
        _disableInitializers(); //impl.getInitialized(): 255
    }

    function stake(address tokenAddr, uint256 _amount) external whenNotPaused {
        IERC20 token = IERC20(tokenAddr);

        token.safeTransferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
    }
}

contract ERC20UStakingV2 is ERC20UStaking {
    using SafeERC20 for IERC20;
    //using SafeERC20Upgradeable for IERC20;
    using Address for address;

    mapping(address => uint256) public rewardRates;

    function setVersion(uint256 _num1) public onlyOwner {
        num1 = _num1;
    }

    function withdraw(address tokenAddr, uint256 _amount) external whenNotPaused {
        IERC20 token = IERC20(tokenAddr);
        token.safeTransfer(msg.sender, _amount);
        staked[msg.sender] -= _amount;
    }
}

contract ERC20UStakingHack is ERC20UStaking {
    //uint256 public num2;
    function attack(uint256 _b) external {
        num1 = _b;
    }
}
