// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/VerifySignature.sol";

contract VerifySignatureTest is Test {
    address zero = address(0);
    address alice = address(1);
    address bob = address(2);
    uint256 num;
    uint256 numM;
    uint256 inputValue = 13;
    uint256 etherValue;
    address fox1;
    address calleeAddr;
    address callerAddr;
    address senderM;
    uint256 ethBalc;
    string mesg;
    string mesgM;
    VerifySignature vSig;
    bytes sig;

    function setUp() public {
        deal(alice, 1000 ether);
        deal(bob, 1000 ether);
        vSig = new VerifySignature();
        calleeAddr = address(vSig);
        fox1 = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
    }

    function test1() public {
        console.log("---------== test1");
        address to = address(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
        uint256 amount = 174;
        mesg = "coffee and donuts";
        uint256 nonce = 0;
        bytes32 mesgHash = vSig.getMessageHash(to, amount, mesg, nonce);
        console.log("mesgHash:");
        console.logBytes32(mesgHash); //0xc50c1e773d6063f7dea3a5c9d1c337e020278c864593b1bfd50d3ee4972adec9
        /* Follow steps in VerifySignature.sol ...
        */

        bytes32 mesgSigned = vSig.getEthSignedMessageHash(mesgHash);
        console.log("mesgSigned:");
        console.logBytes32(mesgSigned); //0x87553ba9375fd551c4954f0c9c34d43807188d83fd3363477652b392bd5fb851

        sig =
            hex"96339e12a5b81bad5d5c9241678484ed4fa6fd6f885a1836e9145f0cdc78b7d17629295d2fa01e261edba71b36998571cc20f192043522518743659698a828f31b";

        address recoveredSigner = vSig.recoverSigner(mesgSigned, sig);
        console.log("RecoveredSigner:", recoveredSigner);
        console.log("Confirm the above signer");

        address signer = fox1;
        bool isVerified = vSig.verifySigner(signer, to, amount, mesg, nonce, sig);
        console.log("isVerified:", isVerified);
        //console.log("successfully verified signer");
    }
}
