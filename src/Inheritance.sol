// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

//https://solidity-by-example.org/inheritance/
/* Graph of inheritance
    A
   / \
  B   C
 / \ /
F  D,E
*/
contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

// Contracts inherit other contracts by using the keyword 'is'.
contract B is A {
    // Override A.foo()
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is A {
    // Override A.foo()
    function foo() public pure virtual override returns (string memory) {
        return "C";
    }
}
// D.foo() returns "C" because C is the right most parent contract with function foo()

contract D is B, C {
    function foo() public pure override(B, C) returns (string memory) {
        return super.foo();
    }
}
// E.foo() returns "B", because B is the right most parent contract with function foo()

contract E is C, B {
    function foo() public pure override(C, B) returns (string memory) {
        return super.foo();
    }
}

// Inheritance must be ordered from “most base-like” to “most derived”. Swapping the order of A and B will throw a compilation error.
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo(); //returns B
    }
}

//---------------------== Constructors
// Base contract X
contract X {
    string public name;

    constructor(string memory _name) {
        console.log("X constructor");
        name = _name;
    }
}

// Base contract Y
contract Y {
    string public text;

    constructor(string memory _text) {
        console.log("Y constructor");
        text = _text;
    }
}

// 2 ways to initialize parent contract with parameters
// 1. if you know the input at developing:
contract G is X("Input to X"), Y("Input to Y") {}

// 2. if you do not know the input at developing:
contract H is X, Y {
    constructor(string memory _name, string memory _text) X(_name) Y(_text) {}
}
// 1+2. if you know some inputs, but not all at developing:

contract GH is X, Y {
    constructor(string memory _name) X(_name) Y("Input to Y") {}
}

// Parent constructors are always called in the order of inheritance regardless of the order of parent contracts listed in the constructor of the child contract.

// Order of constructors called: X, Y, D
contract J is X, Y {
    constructor() X("X was called") Y("Y was called") {}
}

// Order of constructors called: X, Y, E
contract K is X, Y {
    constructor() Y("Y was called") X("X was called") {}
}

//---------------------== Calling Parents
/**
 * E
 *    / \
 *   F   G
 *    \ /
 *     H
 * ... Order = E => F or G => H
 */
contract Ee {
    event Log(string mesg);

    function foo() public virtual {
        emit Log("Ee.foo");
        console.log("Ee.foo");
    }

    function bar() public virtual {
        emit Log("Ee.bar");
        console.log("Ee.bar");
    }
}

contract Ff is Ee {
    function foo() public virtual override {
        emit Log("Ff.foo");
        console.log("Ff.foo");
        Ee.foo(); //calls one parent contract
    }

    function bar() public virtual override {
        emit Log("Ff.bar");
        console.log("Ff.bar");
        super.bar();
    }
}

contract Gg is Ee {
    function foo() public virtual override {
        emit Log("Gg.foo");
        console.log("Gg.foo");
        Ee.foo(); //calls one parent contract
    }

    function bar() public virtual override {
        emit Log("Gg.bar");
        console.log("Gg.bar");
        super.bar();
    }
}

contract Hh is Ff, Gg {
    function foo() public virtual override(Ff, Gg) {
        console.log("Hh.foo");
        Ff.foo(); //calls one parent contract
    }

    function bar() public virtual override(Ff, Gg) {
        console.log("Hh.bar");
        super.bar(); //calls all parents: Gg.foo() and Ff.foo()
    }
}
