// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/*Open Zeppelin Upgradeable Contracts

admin EOA --> ProxyAdmin/upgrade()
          --> Proxy/upgrade()

user EOA  --> ProxyAdmin/fallback() + delegatecall
          --> implementation Ctrt

*/

contract UgOzBoxV1 {
    uint256 public value;

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    // constructor(uint _val) {
    //     val = _val;
    // }

    function initialize(uint256 _value) external {
        value = _value;
    }

    // Stores a new value in the contract
    function set(uint256 _value) public {
        value = _value;
        emit ValueChanged(_value);
    }
}

contract UgOzBoxV2 is UgOzBoxV1 {
    // constructor(uint _val) {
    //     val = _val;
    // }

    // function initialize(uint _value) external {
    //     value = _value;
    // }

    function inc() external {
        value += 1;
        emit ValueChanged(value);
    }
}
