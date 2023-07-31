// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/DelegateCall.sol";

contract DelegateCallTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 inputNumProxy = 5;
    uint256 inputNum = 100;
    uint256 inputValue = 13;
    Proxy proxy;
    Logic logic;
    Logic2 logic2;
    address payable addr1;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        proxy = new Proxy(alice);
        logic = new Logic(alice);
        logic2 = new Logic2(alice);
    }

    function testLogic() public {
        console.log("---------== initiating");
        console.log("proxy ctrt: owner:", proxy.owner());
        assertEq(proxy.owner(), alice);
        console.log("sender:", proxy.sender());
        assertEq(proxy.sender(), zero);
        console.log("num:", proxy.num(), ", value:", proxy.value());
        assertEq(proxy.num(), inputNumProxy);
        assertEq(proxy.value(), 0);

        console.log("logic ctrt: owner:", logic.owner());
        assertEq(logic.owner(), alice);
        console.log("sender:", logic.sender());
        assertEq(logic.sender(), zero);
        console.log("num:", logic.num(), ", value:", logic.value());
        assertEq(logic.num(), 0);
        assertEq(logic.value(), 0);

        console.log("---------== calling delegatecall");
        vm.prank(bob);
        proxy.stake{value: inputValue}(address(logic), inputNum);
        console.log("---------== after delegatecall");
        console.log("proxy ctrt: owner:", proxy.owner());
        assertEq(proxy.owner(), alice);
        console.log("sender:", proxy.sender());
        assertEq(proxy.sender(), bob);
        console.log("num:", proxy.num(), ", value:", proxy.value());
        assertEq(proxy.num(), inputNum);
        assertEq(proxy.value(), inputValue);

        console.log("logic ctrt: owner:", logic.owner());
        assertEq(logic.owner(), alice);
        console.log("sender:", logic.sender());
        assertEq(logic.sender(), zero);
        console.log("num:", logic.num(), ", value:", logic.value());
        assertEq(logic.num(), 0);
        assertEq(logic.value(), 0);
    }

    function testLogic2() public {
        console.log("---------== initiating Logic2{}");
        console.log("proxy ctrt: owner:", proxy.owner());
        assertEq(proxy.owner(), alice);
        console.log("sender:", proxy.sender());
        assertEq(proxy.sender(), zero);
        console.log("num:", proxy.num(), ", value:", proxy.value());
        assertEq(proxy.num(), inputNumProxy);
        assertEq(proxy.value(), 0);

        console.log("logic2 ctrt: owner:", logic2.owner());
        assertEq(logic2.owner(), alice);
        console.log("sender:", logic2.sender());
        assertEq(logic2.sender(), zero);
        console.log("num:", logic2.num(), ", value:", logic2.value());
        assertEq(logic2.num(), 0);
        assertEq(logic2.value(), 0);

        console.log("---------== calling delegatecall");
        vm.prank(bob);
        proxy.stake{value: inputValue}(address(logic2), inputNum);
        console.log("---------== after delegatecall");
        console.log("proxy ctrt: owner:", proxy.owner());
        assertEq(proxy.owner(), alice);
        console.log("sender:", proxy.sender());
        assertEq(proxy.sender(), bob);
        console.log("num:", proxy.num(), ", value:", proxy.value());
        assertEq(proxy.num(), inputNum * 2);
        assertEq(proxy.value(), inputValue);

        console.log("logic2 ctrt: owner:", logic2.owner());
        assertEq(logic2.owner(), alice);
        console.log("sender:", logic2.sender());
        assertEq(logic2.sender(), zero);
        console.log("num:", logic2.num(), ", value:", logic2.value());
        assertEq(logic2.num(), 0);
        assertEq(logic2.value(), 0);

        console.log("---------== Test Added functions");
        console.log("logic2 ctrt: admin:", logic2.admin());
        assertEq(logic2.admin(), zero);
        console.log("num2:", logic2.num2());
        assertEq(logic2.num2(), 0);
    }
}
