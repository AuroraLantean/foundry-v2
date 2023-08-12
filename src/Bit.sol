// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bit {
    struct Store {
        // 0-159: address
        // 160-191: time1 in seconds: uint32
        // 192-223: time2 in seconds: uint32
        // 224-239: uint16
        // 240-247: uint8
        // 248: bool
        // 255: bool
        uint256 data;
        uint256 totalSupply;
    }

    Store store;

    function setAddr(address addr) external {
        store.data |= uint256(uint160(addr));
    }

    function getAddr() external view returns (address addr1) {
        addr1 = address(uint160(store.data));
    }

    function setTime1(uint32 time1) external {
        store.data |= uint256(time1) << 160;
    }

    function getTime1() external view returns (uint32 time1) {
        time1 = uint32(store.data >> 160);
    }

    function setTime2(uint32 time2) external {
        store.data |= uint256(time2) << 192;
    }

    function getTime2() external view returns (uint32 time2) {
        time2 = uint32(store.data >> 192);
    }

    function setNum16(uint16 num16) external {
        store.data |= uint256(num16) << 224;
    }

    function getNum16() external view returns (uint16 num16) {
        num16 = uint16(store.data >> 224);
    }

    function setNum8(uint8 num8) external {
        store.data |= uint256(num8) << 240;
    }

    function getNum8() external view returns (uint8 num8) {
        num8 = uint8(store.data >> 240);
    }

    function setBoolx(bool bool1, uint8 index) external {
        require(index >= 248 && index <= 255, "index invalid");
        uint256 data = uint256(1) << index;
        if (bool1) {
            store.data |= data;
        } else {
            store.data &= ~(data);
        }
    }

    function getBoolx(uint8 index) external view returns (bool boolx) {
        require(index >= 248 && index <= 255, "index invalid");
        boolx = ((store.data >> index) & uint256(1)) == 1;
    }

    //From Uniswap BitMath.sol
    // Find most significant bit using binary search
    // decimal 4 is 0x0100 in binary format. So the "1" is counted from the right side starting from 0, 1, 2
    function mostSignificantBit(uint256 x) external pure returns (uint256 msb) {
        require(x > 0);
        // x >= 2 ** 128
        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            msb += 128;
        }
        // x >= 2 ** 64
        if (x >= 0x10000000000000000) {
            x >>= 64;
            msb += 64;
        }
        // x >= 2 ** 32
        if (x >= 0x100000000) {
            x >>= 32;
            msb += 32;
        }
        // x >= 2 ** 16
        if (x >= 0x10000) {
            x >>= 16;
            msb += 16;
        }
        // x >= 2 ** 8
        if (x >= 0x100) {
            x >>= 8;
            msb += 8;
        }
        // x >= 2 ** 4
        if (x >= 0x10) {
            x >>= 4;
            msb += 4;
        }
        // x >= 2 ** 2
        if (x >= 0x4) {
            x >>= 2;
            msb += 2;
        }
        // x >= 2 ** 1
        if (x >= 0x2) msb += 1;
    }
    
    //From Uniswap BitMath.sol
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}
