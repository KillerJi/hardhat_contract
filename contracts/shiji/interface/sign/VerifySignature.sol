// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SafeMath} from "../SafeMath.sol";
import {EIP712Base} from "./EIP712Base.sol";

contract VerifySignature is EIP712Base {
    using SafeMath for uint256;
    bytes32 private constant CREATE_TRANSACTION_TYPEHASH =
        keccak256(bytes("Claim(address token,address account,uint256 number,uint256 nonce)"));

    struct ClaimTransaction {
        address token;
        address account;
        uint256 number;
        uint256 nonce;
    }

    function hashCreateTransaction(ClaimTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    CREATE_TRANSACTION_TYPEHASH,
                    metaTx.token,
                    metaTx.account,
                    metaTx.number,
                    metaTx.nonce
                )
            );
    }

    function verify(
        address signer,
        address token,
        address account,
        uint256 number,
        uint256 nonce,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "CreateTransaction: INVALID_SIGNER");
        ClaimTransaction memory metaTx = ClaimTransaction({
            token: token,
            account: account,
            number: number,
            nonce: nonce
        });
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashCreateTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}
