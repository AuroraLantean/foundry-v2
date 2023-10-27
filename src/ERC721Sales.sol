//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; //includes IERC20
//totalSupply(), tokenOfOwnerByIndex(address owner, uint256 index), tokenByIndex(uint256 index)

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //includes IERC20, IERC20Permit, Address
//safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol"; //includes IERC721, which includes IERC165.sol
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol"; // includes IERC721
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol"; //includes IERC721Receiver
//import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "forge-std/console.sol";

//------------------------------==
interface IERC721Full is IERC721Enumerable, IERC721Metadata {
    function exists(uint256 tokenId) external view returns (bool);
} // use this instead of the full contract because we only need a few functions like transferFrom, safeTransferFrom, ownerOf, exists, etc...
//----------------------==

contract ERC721Sales is Ownable, ERC721Holder, ReentrancyGuard {
    using SafeERC20 for IERC20Metadata;
    using Address for address;

    uint256 public priceInWeiETH;
    uint256 public priceInWeiToken;
    IERC721Full public erc721;
    IERC20Metadata public token;

    constructor(address _token, address _addrNFT, uint256 _priceInWeiETH, uint256 _priceInWeiToken)
        Ownable(msg.sender)
    {
        require(_token != address(0) || _addrNFT != address(0), "should not be zero");
        require(_token.code.length != 0 || _addrNFT.code.length != 0, "should be contracts");
        token = IERC20Metadata(_token);
        erc721 = IERC721Full(_addrNFT);
        priceInWeiETH = _priceInWeiETH;
        priceInWeiToken = _priceInWeiToken;
    }

    function setNFT(address _addrNFT) external onlyOwner {
        require(_addrNFT != address(0) && _addrNFT.code.length != 0, "input invalid");
        erc721 = IERC721Full(address(_addrNFT));
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0) && _token.code.length != 0, "input invalid");
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

    function checkBuying(uint256 _tokenId) public view returns (address owner, bool obool) {
        bool b1 = erc721.exists(_tokenId);
        owner = erc721.ownerOf(_tokenId);
        bool b2 = msg.sender != address(0) && msg.sender != address(this) && msg.sender != owner;
        obool = b1 && b2;
    }

    function buyNFTviaETH(uint256 _tokenId) external payable {
        (address owner, bool obool) = checkBuying(_tokenId);
        require(obool, "invalid input");
        require(msg.value >= priceInWeiETH, "ETH amount invalid");
        erc721.safeTransferFrom(owner, msg.sender, _tokenId);
        emit BuyNFTViaETH(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function buyNFTviaERC20(uint256 _tokenId) external {
        (address owner, bool obool) = checkBuying(_tokenId);
        require(obool, "invalid input");

        token.safeTransferFrom(msg.sender, address(this), priceInWeiToken);

        erc721.safeTransferFrom(owner, msg.sender, _tokenId);
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
        if (msg.value > 0) {
            revert();
        }
    }

    event WithdrawETH(address indexed payee, uint256 amount, uint256 balance);
    event WithdrawERC20(address indexed payee, uint256 amount, uint256 balance);
    event BuyNFTViaETH(address indexed payer, uint256 indexed tokenId, uint256 amount, uint256 balance);
    event BuyNFTViaERC20(address indexed payer, uint256 indexed tokenId, uint256 amount, uint256 balance);

    //---------------==
    function getBalances() public view returns (uint256[] memory out) {
        address sender = msg.sender;
        address tis = address(this);
        out = new uint256[](7);
        out[0] = sender.balance;
        out[1] = token.balanceOf(sender);
        out[2] = uint256(token.decimals());
        out[3] = erc721.balanceOf(sender);
        out[4] = tis.balance;
        out[5] = token.balanceOf(tis);
        out[6] = erc721.balanceOf(tis);
    }
}

contract ArrayOfStructs {
    struct Box {
        uint256 num;
        address owner;
    }

    mapping(uint256 => Box) public boxes;

    constructor(uint256 num) {
        address owner = msg.sender;
        boxes[0] = Box(num, owner);
        boxes[1] = Box(num + 1, owner);
        boxes[2] = Box(num + 2, owner);
    }

    function addBox(uint256 id, uint256 num, address owner) public returns (bool) {
        boxes[id] = Box(num, owner);
        return true;
    }

    function getBox(uint256 id) public view returns (Box memory) {
        return boxes[id];
    }

    function getBox2(uint256 id) public view returns (Box memory box) {
        box = boxes[id];
    }

    function getTuple() public pure returns (string memory, uint8, uint256) {
        return ("string", type(uint8).max, type(uint256).max);
    }

    function getBoxes(uint256 min, uint256 max) public view returns (Box[] memory) {
        uint256 arrlength = max - min + 1;
        Box[] memory out = new Box[](arrlength);
        for (uint256 i = min; i < arrlength; i++) {
            out[i] = boxes[i];
        }
        return out;
    }

    function getBoxes2(uint256 min, uint256 max) public view returns (Box[] memory out) {
        uint256 arrlength = max - min + 1;
        out = new Box[](arrlength);
        for (uint256 i = 0; i < arrlength; i++) {
            out[i] = boxes[i];
        }
    }

    function getBalances(address _token) public view returns (uint256[] memory out) {
        address sender = msg.sender;
        IERC20Metadata token = IERC20Metadata(_token);
        //address tis = address(this);
        out = new uint256[](7);
        out[0] = sender.balance;
        out[1] = token.balanceOf(sender);
        out[2] = uint256(token.decimals());
        out[3] = 10; //erc721.balanceOf(sender);
        out[4] = 0; //tis.balance;
        out[5] = 0; //token.balanceOf(tis);
        out[6] = 0; //erc721.balanceOf(tis);
    }
}
