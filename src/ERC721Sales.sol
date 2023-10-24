//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "xyz";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; //includes IERC20
//totalSupply(), tokenOfOwnerByIndex(address owner, uint256 index), tokenByIndex(uint256 index)

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //includes IERC20, IERC20Permit, Address
//safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol"; //includes IERC721, which includes IERC165.sol
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol"; // includes IERC721
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol"; //includes IERC721Receiver

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "forge-std/console.sol";

//------------------------------==
interface IERC721Full is IERC165, IERC721Metadata, IERC721Enumerable {
    function exists(uint256 tokenId) external view returns (bool);
} // use this instead of the full contract because we only need a few functions like transfer and transferFrom, etc...
//----------------------==

contract ERC721Sales is Ownable, ERC721Holder, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public priceInWeiETH;
    uint256 public priceInWeiToken;
    IERC721Full public ierc721;
    IERC20 public token;

    constructor(address _token, address _addrNFT, uint256 _priceInWeiETH, uint256 _priceInWeiToken) {
        require(_token != address(0) || _addrNFT != address(0), "should not be zero");
        require(_token.isContract() || _addrNFT.isContract(), "should be contracts");
        token = IERC20Metadata(_token);
        ierc721 = IERC721Full(address(_addrNFT));
        priceInWeiETH = _priceInWeiETH;
        priceInWeiToken = _priceInWeiToken;
    }

    function setNFT(address _addrNFT) external onlyOwner {
        require(_addrNFT != address(0) && _addrNFT.isContract(), "input invalid");
        ierc721 = IERC721Full(address(_addrNFT));
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0) && _token.isContract(), "input invalid");
        token = IERC20Metadata(_token);
    }

    function setPriceInWeiETH(uint256 _priceInWeiETH) external onlyOwner {
        require(_priceInWeiETH > 0, "input invalid");
        priceInWeiETH = _priceInWeiETH;
    }

    function setPriceInWeiToken(uint256 _priceInWeiToken) external onlyOwner {
        require(_priceInWeiToken > 0, "input invalid");
        priceInWeiToken = _priceInWeiToken;
    }

    function checkBuying(uint256 _tokenId) public view returns (address owner) {
        require(ierc721.exists(_tokenId));
        owner = ierc721.ownerOf(_tokenId);
        require(msg.sender != address(0) && msg.sender != address(this) && msg.sender != owner, "invalid sender");
    }

    function buyNFTviaETH(uint256 _tokenId) external payable {
        (address owner) = checkBuying(_tokenId);
        require(msg.value >= priceInWeiETH, "ETH amount invalid");
        ierc721.safeTransferFrom(owner, msg.sender, _tokenId);
        emit BuyNFTViaETH(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function buyNFTviaERC20(uint256 _tokenId) external {
        (address owner) = checkBuying(_tokenId);

        token.safeTransferFrom(msg.sender, address(this), priceInWeiToken);

        ierc721.safeTransferFrom(owner, msg.sender, _tokenId);
        emit BuyNFTViaERC20(msg.sender, _tokenId, priceInWeiToken, address(this).balance);
    }

    function withdrawETH(address payable _to, uint256 _amount) external onlyOwner nonReentrant {
        require(_to != address(0) && _to != address(this), "to address invalid");
        require(_amount > 0, "amount invalid");
        Address.sendValue(_to, _amount); //check this ctrt ETH balance >= amount
        //payable(address(_to)).transfer(_amount);
        emit WithdrawETH(_to, _amount, address(this).balance);
    }

    function withdrawERC20(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0) && _to != address(this), "to address invalid");
        require(_amount > 0 && _amount <= token.balanceOf(address(this)), "amount invalid");
        token.safeTransfer(_to, _amount);
        emit WithdrawERC20(_to, _amount, token.balanceOf(address(this)));
    }

    fallback() external payable {}

    receive() external payable {
        //called when the call data is empty
        if (msg.value > 0) {
            revert();
        }
    }
    //---------------==

    event WithdrawETH(address indexed payee, uint256 amount, uint256 balance);
    event WithdrawERC20(address indexed payee, uint256 amount, uint256 balance);
    event BuyNFTViaETH(address indexed payer, uint256 indexed tokenId, uint256 amount, uint256 balance);
    event BuyNFTViaERC20(address indexed payer, uint256 indexed tokenId, uint256 amount, uint256 balance);
}
/* 
      ierc721.safeTransferFrom(from, to, tokenId);
      ierc721.safeTransferFrom(from, to, tokenId, data);
      ierc721.transferFrom(from, to, tokenId);

    //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/ERC721ReceiverMock.sol
    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        require(operator != address(0), "operator invalid");
        require(tokenId > 0, "tokenId invalid");
        emit Received(operator, from, tokenId, data, gasleft());
        //const bytesfour = bytes4(data);
        //bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
        return this.onERC721Received.selector;
    }
 */
