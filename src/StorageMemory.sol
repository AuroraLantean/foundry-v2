// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct Item {
        uint256 foo;
    }

    mapping(uint256 => Item) items;
    string public text;

    function f() public {
        // call _f with state variables
        _f(arr, map, items[1]);

        // get a struct from a mapping
        Item storage item = items[1];
        // make a struct in memory
        Item memory itemMem = Item(0);
        console.log(item.foo, itemMem.foo);
    }

    function _f(uint256[] storage _arr, mapping(uint256 => address) storage _map, Item storage _item) internal {
        // do something with storage variables
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // do something with memory array
    }

    function h(uint256[] calldata _arr) external {
        // do something with calldata array
    }

    function get() external view returns (string memory) {
        return text;
    }

    function set(string calldata _text) external {
        text = _text;
    }
}

contract Todos {
    struct Todo {
        string text;
        bool completed;
    }

    // An array of 'Todo' structs
    Todo[] public todos;

    function make(string calldata _text) public {
        // 3 ways to initialize a struct
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        todos.push(Todo({text: _text, completed: false}));

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false

        todos.push(todo);
    }

    // Solidity automatically made a getter for 'todos' so
    // you don't actually need this function.
    function get(uint256 _index) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index]; //storage costs less gas then memory
        return (todo.text, todo.completed);
    }

    function getStruct(uint256 _index) public view returns (Todo memory) {
        return todos[_index]; //storage is auto converted to memory, but not for calldata!
    }

    function updateText(uint256 _index, string calldata _text) public {
        todos[_index].text = _text; //Cheaper on gas and SHORTER syntax
            //Todo storage todo = todos[_index];//access array only once... used if you have to update multiple fields or update the same field multiple times
            //todo.text = _text;
    }

    function toggleCompleted(uint256 _index) public {
        todos[_index].completed = !todos[_index].completed;
        //Todo storage todo = todos[_index];
        //todo.completed = !todo.completed;
    }
}
