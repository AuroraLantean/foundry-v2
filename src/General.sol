// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract General {
    //-----------== Array
    address public owner;
    address public sender;
    uint256 public num;
    uint256 public value;
    uint256[] public arr = [1, 2, 3, 4, 5, 6];

    //-----------== Array, Struct, and Mapping
    uint256 public cindex;

    struct Item {
        uint256 num;
        address ctrt;
    }
    //rotaryState rState;//enum

    mapping(address => Item[]) public itemsByOwner;

    function addItem(uint256 _num) public {
        arr.push(_num);
    }

    function getItem(uint256 index) public view returns (uint256) {
        return arr[index];
    }

    function addMapItem(uint256 _num) public {
        itemsByOwner[msg.sender].push(Item(_num, address(0)));
        cindex++;
    }

    function updateMapItem(uint256 index, uint256 _num) public {
        itemsByOwner[msg.sender][index].num = _num;
    }

    function getMapItemSize(address _owner) public view returns (uint256 size) {
        size = itemsByOwner[_owner].length;
    }

    function getMapItem(address _owner, uint256 index) public view returns (Item memory) {
        require(index < itemsByOwner[_owner].length, "Index out of bounds");
        return itemsByOwner[_owner][index];
        //return itemsByOwner[_owner][index].num;
    }

    //-----------==
    constructor(address _owner) {
        owner = _owner;
    }

    function getLength() public view returns (uint256) {
        return arr.length;
    }
    // ArrayRemoveByShifting
    // [1, 2, 3] -- remove(1) --> [1, 3, 3] --> [1, 3]
    // [1, 2, 3, 4, 5, 6] -- remove(2) --> [1, 2, 4, 5, 6, 6] --> [1, 2, 4, 5, 6]
    // [1, 2, 3, 4, 5, 6] -- remove(0) --> [2, 3, 4, 5, 6, 6] --> [2, 3, 4, 5, 6]
    // [1] -- remove(0) --> [1] --> []

    function removeWithOrder(uint256 idx) public returns (uint256 removed) {
        //console.log("removeWithOrder()... idx:", idx);
        require(idx < arr.length, "idx out of bound");

        removed = arr[idx];
        for (uint256 i = idx; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        //delete arr[arr.length-1];
        arr.pop(); // shrink array size by 1 // arr.length--;
    }

    function removeSwap(uint256 idx) public returns (uint256 removed) {
        require(idx < arr.length, "idx out of bound");
        removed = arr[idx];
        arr[idx] = arr[arr.length - 1];
        //delete arr[arr.length - 1];
        arr.pop(); // shrink array size by 1
    }
}

contract Immutable {
    // immutable variables can only be set ONCE (in constructors or just outside of functions)! Then they will not be changed!
    // cost less gas than usual variables
    // coding convention to uppercase constant variables
    address public immutable MY_ADDRESS;
    uint256 public immutable MY_UINT;

    constructor(uint256 _myUint) {
        MY_ADDRESS = msg.sender;
        MY_UINT = _myUint;
    }
}
