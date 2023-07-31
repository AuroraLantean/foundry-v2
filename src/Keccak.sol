// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract Keccak {
    function hash(string memory _text, uint256 _num, address _addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    function encode(string memory text0, string memory text1) public pure returns (bytes memory) {
        return abi.encode(text0, text1);
    }

    function encodePacked(string memory text0, string memory text1) public pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }

    // Example of hash collision
    // Hash collision can occur when you pass more than one dynamic data type to abi.encodePacked. In such case, you should use abi.encode instead.
    function hashTxTx(string memory _text, string memory _anotherText) public pure returns (bytes32) {
        // encodePacked(AAA, BBB) -> AAABBB
        // encodePacked(AA, ABBB) -> AAABBB
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
    //Separate dynamical inputs... Best!

    function hashTxUtTx(string memory _text, uint256 x, string memory _anotherText) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text, x, _anotherText));
    }
    //use abi.encode without pack!

    function hashTxTx2(string memory _text, string memory _anotherText) public pure returns (bytes32) {
        return keccak256(abi.encode(_text, _anotherText));
    }

    //---------------== Guess the magic word
    bytes32 public answer = 0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;
    // Magic word is "Solidity"

    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}
