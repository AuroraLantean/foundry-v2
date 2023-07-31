// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/Inheritance.sol";

contract DelegateCallTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNumProxy = 5;
    uint256 inputNum = 100;
    uint256 inputValue = 13;
    address payable addr1;
    A a;
    B b;
    C c;
    D d;
    E e;
    F f;
    J j;
    K k;
    Ff ff;
    Gg gg;
    Hh hh;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        a = new A();
        b = new B();
        c = new C();
        d = new D();
        e = new E();
        f = new F();
    }

    function test1() public {
        console.log("---------== test1");
        string memory str = a.foo();
        assertEq(str, "A");

        str = b.foo();
        assertEq(str, "B");
        str = c.foo();
        assertEq(str, "C");

        str = d.foo();
        assertEq(str, "C");
        str = e.foo();
        assertEq(str, "B");

        str = f.foo();
        assertEq(str, "B");

        j = new J();
        k = new K();
    }

    function test2() public {
        console.log("---------== test2");
        hh = new Hh();
        console.log("----==Test on specified calling");
        hh.foo();

        console.log("----==Test on super");
        hh.bar();
    }
}
