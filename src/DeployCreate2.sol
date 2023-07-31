// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

// See tests at "DeployAtSameAddr.t.sol"
// NEWER way to invoke create2 without assembly
contract Factory {
    // Returns the address of the newly deployed contract
    function deploy(address _owner, uint256 _num, bytes32 _salt) public payable returns (address) {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        return address(new Ctrt{salt: _salt}(_owner, _num));
    }

    function predictSaltedAddr(address _owner, uint256 _num, bytes32 _salt) public view returns (address) {
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            _salt,
                            keccak256(abi.encodePacked(type(Ctrt).creationCode, abi.encode(_owner, _num)))
                        )
                    )
                )
            )
        );
    }
}

// OLDER way of doing it using assembly`
contract FactoryAssembly {
    event Deployed(address addr, uint256 salt);

    // 1. Get bytecode of contract to be deployed
    // NOTE: _owner and _num are arguments of the Ctrt's constructor
    function getBytecodeWithArgs(address _owner, uint256 _num) public pure returns (bytes memory) {
        bytes memory bytecode = type(Ctrt).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner, _num));
    }

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getDeploymentAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))); //address(this) is the deployer address

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    // 3. Deploy the contract
    // NOTE: Check the event log Deployed which contains the address of the deployed Ctrt. The address in the log should equal the address computed from above.
    function deploy(bytes memory bytecode, uint256 _salt) public payable {
        address addr;

        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            addr :=
                create2(
                    callvalue(), // wei sent with current call
                    // Actual code starts after skipping the first 32 bytes
                    add(bytecode, 0x20),
                    mload(bytecode), // Load the size of code contained in the first 32 bytes
                    _salt // Salt from function arguments
                )

            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        emit Deployed(addr, _salt);
    }
}

contract Ctrt {
    address public owner;
    uint256 public num;

    constructor(address _owner, uint256 _num) payable {
        owner = _owner;
        num = _num;
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    function setNum(uint256 _num) public {
        require(msg.sender == owner, "not owner");
        num = _num;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Ctrt2 {
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) payable {
        x = _x;
        y = _y;
    }
}
