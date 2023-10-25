// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
// import
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; //_mint, _burn
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
//safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance

import "@openzeppelin/contracts/access/Ownable.sol"; //owner(), onlyOwner, renounceOwnership, transferOwnership,

import "@openzeppelin/contracts/utils/Pausable.sol"; //paused, whenNotPaused, whenPaused, _pause, _unpause

//import "@openzeppelin/contracts/utils/introspection/ERC1820Implementer.sol";

//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/ERC1155Mock.sol
//from ERC1155.sol
contract ERC1155oz is Ownable, ERC1155 {
    constructor(string memory uri) Ownable(msg.sender) ERC1155(uri) {
        //console.log("[c] initializer");
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyOwner returns (bool) {
        _mint(to, id, amount, data);
        return true;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
        returns (bool)
    {
        _mintBatch(to, ids, amounts, data);
        return true;
    }

    function burn(address owner, uint256 id, uint256 amount) public onlyOwner returns (bool) {
        _burn(owner, id, amount);
        return true;
    }

    function burnBatch(address owner, uint256[] memory ids, uint256[] memory amounts) public onlyOwner returns (bool) {
        _burnBatch(owner, ids, amounts);
        return true;
    }
}

//------------------------------==
//------------------------------==
contract ERC1155Receiver is Ownable, Pausable, ERC165, IERC1155Receiver {
    //using Address for address;

    //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/ERC1155ReceiverMock.sol
    bytes4 private _recRetval;
    bool private _recReverts;
    bytes4 private _batRetval;
    bool private _batReverts;

    event Received(address operator, address from, uint256 id, uint256 amount, bytes data, uint256 gas);
    event BatchReceived(address operator, address from, uint256[] ids, uint256[] amounts, bytes data, uint256 gas);

    function onERC1155Received(address operator, address from, uint256 id, uint256 amount, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        require(!_recReverts, "ERC1155ReceiverMock: reverting on receive");
        emit Received(operator, from, id, amount, data, gasleft());
        return _recRetval;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override returns (bytes4) {
        require(!_batReverts, "ERC1155ReceiverMock: reverting on batch receive");
        emit BatchReceived(operator, from, ids, amounts, data, gasleft());
        return _batRetval;
    }

    //---------------==
    ERC1155oz public erc1155;

    constructor(ERC1155oz _erc1155) Ownable(msg.sender) {
        require(address(_erc1155) != address(0), "invalid token address");
        require(address(_erc1155).code.length != 0, "is NOT a contract");
        erc1155 = _erc1155;

        _recRetval = 0xf23a6e61;
        _batRetval = 0xbc197c81;
    }

    function safeTransferFrom(
        address erc1155Addr,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) public {
        IERC1155(erc1155Addr).safeTransferFrom(from, to, tokenId, amount, data);
    }

    //only for this contract owner to pause this contract
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    //only for this contract owner to unpause this contract
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
}
