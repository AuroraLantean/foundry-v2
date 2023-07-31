// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
//https://solidity-by-example.org/sending-ether/

contract Counter {
    uint256 public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

interface ICounter {
    function count() external view returns (uint256);
    function inc() external;
}

interface IDataStore {
    function getData() external view returns (uint256);
    function addData(uint256 id) external;
}

contract Caller {
    ICounter icounter;

    function setInterface(address _counter) external {
        icounter = ICounter(_counter);
    }

    function inc() external {
        icounter.inc();
        //ICounter(_counter).inc();
    }

    function getCount() external view returns (uint256) {
        return icounter.count();
        //return ICounter(_counter).count();
    }

    function isExistingInvestor(address _investor, IDataStore dataStore) internal view returns (bool) {
        console.log("isExistingInvestor()...", _investor, address(dataStore));
        uint256 data = 1;
        //uint256 data = dataStore.getUint256(_getKey(WHITELIST, _investor));
        return uint8(data) == 0 ? false : true;
    }
}

//---------------------== Uniswap example
interface UniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface UniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract UniswapExample {
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getTokenReserves() external view returns (uint256, uint256) {
        address pair = UniswapV2Factory(factory).getPair(dai, weth);
        (uint256 reserve0, uint256 reserve1,) = UniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}
