// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console.sol";

/* Signature Verification
How to Sign and Verify
# Private keys Sign
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Public keys Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

contract VerifySignature {
    function getMessageHash(address _to, uint256 _amount, string memory _message, uint256 _nonce)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    /* Steps
    # in browser console: ethereum.enable()
      login to MetaMask and connect to current website 
    
    in the browser console: 
    ... click on the returned Promise object... confirm it shows "fulfilled"

    type commands below in the browser console:
      account = "0x... your account of signer here"
      hash = "0x... from getMessageHash()"

    Use MetaMask to sign:
      ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)
    Or
    Use web3 to sign:
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Then copy the returned signature, pasted into VerifySignature.t.sol as variable sig, but REMOVE leading "0x"... so it looks like sig= hex"...";
    But in Remix recoverSigner input field, you keep the "0x"

    recoverSigner() should recover the signer...
    confirm the recovered sign matches the account you used to sign the message... The End.

    */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /* 4. Verify signature    */
    function verifySigner(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature); //r and s are cryptographic parameters used for signatures. v is unique to Ethereum

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length"); //because r and s has 32 length, and v is one byte and one length. So 32+32+1 = 65

        assembly {
            /* Sig is a dynamic data. Any dynamic data's first 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
