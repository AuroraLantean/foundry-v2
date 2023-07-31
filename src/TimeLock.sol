// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

// to publish a transaction to be executed in the future(24 hours to several days);commonly used in DAOs.
// Useful for users to inspect what the contract owner is about to do in the near future...
// if an user determines that the contract owner is malicious, the user can withdraw the fund
contract TimeLock {
    error NotOwnerError();
    error TxIdAlreadyAddedError(bytes32 txId);
    error TimestampNotInRangeError(uint256 blockTimestamp, uint256 _executeTimeMin);
    error TxIdNotAddedError(bytes32 txId);
    error TimeNotYetError(uint256 blockTimestmap, uint256 _executeTimeMin);
    error TimeExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error TxFailedError();

    event AddTxId(
        bytes32 indexed txId, address indexed target, uint256 value, string func, bytes data, uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId, address indexed target, uint256 value, string func, bytes data, uint256 timestamp
    );
    event Cancel(bytes32 indexed txId);

    uint256 public immutable MIN_DELAY; //1 day to 2 wks
    uint256 public immutable MAX_DELAY; //30 days
    uint256 public immutable EXECUTION_PERIOD; // period to execute txn

    address public owner;
    // tx id => isValid
    mapping(bytes32 => bool) public isValid;

    constructor(uint256 minDelay, uint256 maxDelay, uint256 executionPeriod) {
        owner = msg.sender;
        MIN_DELAY = minDelay;
        MAX_DELAY = maxDelay;
        EXECUTION_PERIOD = executionPeriod;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    receive() external payable {}

    function getTxId(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _executeTimeMin
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _data, _executeTimeMin));
    }

    /**
     * @param _target Address of contract or account to call
     * @param _value Amount of ETH to send
     * @param _func Function signature, for example "foo(address,uint256)"
     * @param _data ABI encoded data send.
     * @param _executeTimeMin the time after which the transaction can be executed.
     */
    function addTxId(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _executeTimeMin
    ) external onlyOwner returns (bytes32 txId) {
        console.log("---------== addTxId()");
        // make txId
        txId = getTxId(_target, _value, _func, _data, _executeTimeMin);

        // check if txId is unique
        if (isValid[txId]) {
            revert TxIdAlreadyAddedError(txId);
        }
        console.log("check1");

        // Check timestamp is between now+min and now+max
        // ---|------------|---------------|-------
        //  now    now + min     now + max
        if (_executeTimeMin < block.timestamp + MIN_DELAY || _executeTimeMin > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRangeError(block.timestamp, _executeTimeMin);
        }
        console.log("check2");
        // mark this txId status
        isValid[txId] = true;

        emit AddTxId(txId, _target, _value, _func, _data, _executeTimeMin);
    }

    function execute(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _executeTimeMin
    ) external payable onlyOwner returns (bytes memory) {
        console.log("---------== execute()");
        bytes32 txId = getTxId(_target, _value, _func, _data, _executeTimeMin);
        //check if tx is quued
        if (!isValid[txId]) {
            revert TxIdNotAddedError(txId);
        }
        console.log("check1");
        // ----|-------------------|-------
        //  now    now + EXECUTION_PERIOD
        // less then _executeTimeMin
        if (block.timestamp < _executeTimeMin) {
            revert TimeNotYetError(block.timestamp, _executeTimeMin);
        }
        console.log("check2");
        // over EXECUTION_PERIOD
        if (block.timestamp > _executeTimeMin + EXECUTION_PERIOD) {
            revert TimeExpiredError(block.timestamp, _executeTimeMin + EXECUTION_PERIOD);
        }
        //mark this txId status
        isValid[txId] = false;
        console.log("check3");

        // prepare data
        bytes memory data;
        if (bytes(_func).length > 0) {
            // data = func selector + _data as func arguments
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            // there is no function signature. only data
            data = _data;
        }
        console.log("check4");

        require(address(this).balance >= _value, "TimeLock has not enough fund");
        // execute txn via calling target
        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError();
        }
        console.log("check5");

        emit Execute(txId, _target, _value, _func, _data, _executeTimeMin);
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        console.log("---------== cancel()");
        if (!isValid[_txId]) {
            revert TxIdNotAddedError(_txId);
        }
        console.log("check1");
        isValid[_txId] = false;
        emit Cancel(_txId);
    }

    function getTime() external view returns (uint256) {
        return block.timestamp;
    }
}

contract Destination {
    address public timeLockAddr;
    uint256 public num;

    constructor(address _timeLockAddr) {
        timeLockAddr = _timeLockAddr;
    }

    function dest1() external {
        require(msg.sender == timeLockAddr, "not TimeLock address");
        console.log("---------== dest1()");
        num += 1;
        console.log("num:", num);
        // upgrade contract
        // transfer funds
        // switch price oracle
    }
}
