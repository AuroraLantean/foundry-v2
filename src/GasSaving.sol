// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

// gas saving
contract GasSaving {
    /**
     * # use Private variables
     * # use calldata and storage, instead of memory
     * # use immutable to fix contact addresses, ower addresses, unit, etc...
     * # use msg.sender, instead of state variables
     *
     * # start - 50908 gas
     * # replace memory with calldata - 49163 gas
     * # load state variables to memory for calculation, then load the result back to state variables - 48952 gas
     * # short circuit (bariableA & variableB) to (exprA & exprB) - 48634 gas
     * # loop increments: change i+=1 and i++ to ++i - 48244 gas
     * # omit for loop incrementor
     * # cache array length as a variable - 48209 gas
     * # load each array element to a memory variable - 48047 gas
     * # use require() + unchecked { ... } for overflow/underflow - 47309 gas
     */
    uint256 public total;

    // start - not gas optimized
    // [1, 2, 3, 4, 5, 100]
    function sumEvenAndLessThan99MoreGas(uint256[] memory nums) external {
        for (uint256 i = 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    // gas optimized
    // [1, 2, 3, 4, 5, 100]
    function sumEvenAndLessThan99(uint256[] calldata nums) external {
        //stack variable is cheaper than using state variables
        uint256 _total = total;
        uint256 len = nums.length;

        for (uint256 i = 0; i < len;) {
            uint256 num = nums[i];
            if (num % 2 == 0 && num < 99) {
                _total += num;
            }
            unchecked {
                ++i;
            }
        }

        total = _total;
    }
}
