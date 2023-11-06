// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console.sol";

//inheritance order matters!
contract ERC721Token is Ownable, ERC721Burnable, ERC721Enumerable, ERC721URIStorage {
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, uint256 minTokenId, uint256 maxTokenId)
        Ownable(msg.sender)
        ERC721(name, symbol)
    {
        _safeMintBatch(msg.sender, minTokenId, maxTokenId);
    }

    function safeMintToGuest(address to, uint256 minTokenId) public {
        _safeMintBatch(to, minTokenId, minTokenId + 2);
    }

    function safeMint(address to, uint256 minTokenId, uint256 maxTokenId) public onlyOwner {
        _safeMintBatch(to, minTokenId, maxTokenId);
    }

    function _safeMintBatch(address to, uint256 minTokenId, uint256 maxTokenId) private {
        for (uint256 tokenId = minTokenId; tokenId <= maxTokenId; tokenId++) {
            //if (exists(tokenId)) { continue;}
            _safeMint(to, tokenId);
        }
    }

    function safeApproveBatch(address to, uint256 minTokenId, uint256 maxTokenId) public onlyOwner {
        for (uint256 tokenId = minTokenId; tokenId <= maxTokenId; tokenId++) {
            if (exists(tokenId)) {
                approve(to, tokenId);
            }
        }
    }

    function safeTransferFromBatch(address from, address to, uint256 minTokenId, uint256 maxTokenId) public {
        for (uint256 tokenId = minTokenId; tokenId <= maxTokenId; tokenId++) {
            if (exists(tokenId)) {
                safeTransferFrom(from, to, tokenId, "");
            }
        }
    }

    function ownerOfBatch(uint256 minTokenId, uint256 maxTokenId) public view returns (address[] memory addrs) {
        uint256 arrlength = maxTokenId - minTokenId + 1;
        addrs = new address[](arrlength);
        for (uint256 tokenId = minTokenId; tokenId <= maxTokenId; tokenId++) {
            addrs[tokenId] = _ownerOf(tokenId);
        }
    }

    function getApprovedBatch(uint256 minTokenId, uint256 maxTokenId) public view returns (address[] memory addrs) {
        uint256 arrlength = maxTokenId - minTokenId + 1;
        addrs = new address[](arrlength);
        for (uint256 tokenId = minTokenId; tokenId <= maxTokenId; tokenId++) {
            addrs[tokenId] = getApproved(tokenId);
        }
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) public onlyOwner {
        _safeMint(to, tokenId, _data);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    //ERC721Enumerable
    function _update(address to, uint256 tokenId, address auth)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    //ERC721Enumerable
    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    //ERC721, ERC721Enumerable, ERC721URIStorage
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Already included in ERC721Burnable!!!
    // function burn(uint256 tokenId) public override {}
    /*function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    } */

    //ERC721URIStorage
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    //ERC721URIStorage
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        _setTokenURI(tokenId, _tokenURI);
    }
}

contract ERC721Receiver is IERC721Receiver {
    event OnERC721Received(address indexed operator, address indexed from, uint256 indexed tokenId, bytes data);

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    // Equals to `bytes4(keccak256(abi.encodePacked("onERC721Received(address,address,uint256,bytes)")))`
    // OR IERC721Receiver.onERC721Received.selector

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        console.log("onERC721Received");
        emit OnERC721Received(operator, from, tokenId, data);
        return _ERC721_RECEIVED;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function safeTransferFrom(address erc721Addr, address from, address to, uint256 tokenId) public {
        IERC721(erc721Addr).safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address erc721Addr, address from, address to, uint256 tokenId, bytes calldata data)
        public
    {
        IERC721(erc721Addr).safeTransferFrom(from, to, tokenId, data);
    }

    function transferFrom(address erc721Addr, address from, address to, uint256 tokenId) public {
        IERC721(erc721Addr).transferFrom(from, to, tokenId);
    }

    function makeBytes() public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("onERC721Received(address,address,uint256,bytes)")));
    }

    function makeBytes2() public pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {
        revert("should not send any ether directly");
    }
}
