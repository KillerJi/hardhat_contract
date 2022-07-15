// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/Ownable.sol";
import "./ERC1155.sol";
import "./interface/SafeMath.sol";
import "./interface/IERC20.sol";
import "./interface/Strings.sol";
import "./interface/sign/VerifySignature.sol";
import "hardhat/console.sol";

contract NftRight is ERC1155, Ownable, VerifySignature {
    using Strings for string;
    using SafeMath for uint256;

    mapping(uint256 => address) public creators;
    mapping(uint256 => address) public contractor;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(address => bool) public payStatus;
    mapping(address => mapping(uint256 => bool)) public userClaimFlag;
    mapping(address => mapping(address => uint256)) public _nonce;
    mapping(uint256 => address) public tokenAdd;
    address public nftMarketAdd;
    uint256 constant maxMintNum = 1500;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    // uint256 private nonce;

    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    event SetURI(address add, string newUri);
    event ContractorMint(
        address[] receiver,
        uint256[] tokenId,
        address[] token
    );
    event ContractorMintTo(
        address[] receiver,
        uint256[] tokenId,
        uint256[] num
    );
    event DepositFee(uint256[] fee, uint256[] tokenId, address[] token);
    event Claim(address token, address account, uint256 number);
    event TransferContractor(
        address contractor,
        address receiver,
        uint256 tokenId
    );

    constructor(
        string memory _712name,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        _initializeEIP712(_712name);
        name = _name;
        symbol = _symbol;
    }

    function contractorMint(
        address[] memory receiver,
        uint256[] memory tokenId,
        address[] memory token
    ) public onlyOwner {
        require(receiver.length == tokenId.length, "amounts length mismatch");
        bytes memory nullbytes = "";
        for (uint256 i = 0; i < tokenId.length; i++) {
            require(!_exists(tokenId[i]), "tokenId already exists");
            require(
                contractor[tokenId[i]] == address(0),
                "tokenId already exists"
            );
            creators[tokenId[i]] = _msgSender();
            contractor[tokenId[i]] = receiver[i];
            _mint(receiver[i], tokenId[i], 1, nullbytes);
            _mint(msg.sender, tokenId[i], 1, nullbytes);
            tokenSupply[tokenId[i]] += 2;
            tokenAdd[tokenId[i]] = token[i];
        }

        emit ContractorMint(receiver, tokenId, token);
    }

    function transferContractor(address receiver, uint256 tokenId) public {
        require(contractor[tokenId] == msg.sender, "Not contractor");
        require(receiver != address(0), "Error receiver address");
        contractor[tokenId] = receiver;
        emit TransferContractor(msg.sender, receiver, tokenId);
    }

    function contractorMintTo(
        address[] memory receiver,
        uint256[] memory tokenId,
        uint256[] memory num
    ) public {
        require(
            receiver.length == tokenId.length && tokenId.length == num.length,
            "amounts length mismatch"
        );
        bytes memory nullbytes = "";
        for (uint256 i = 0; i < tokenId.length; i++) {
            require(contractor[tokenId[i]] == msg.sender, "No contractor");
            require(
                (tokenSupply[tokenId[i]] + num[i]) <= maxMintNum,
                "exceeds the maximum"
            );
            require(num[i] >= 1, "num error");
            _mint(receiver[i], tokenId[i], num[i], nullbytes);
            tokenSupply[tokenId[i]] += num[i];
        }
        emit ContractorMintTo(receiver, tokenId, num);
    }

    function depositFee(
        uint256[] memory fee,
        uint256[] memory tokenId,
        address[] memory token
    ) public payable onlyOwner {
        require(fee.length == tokenId.length, "amounts length mismatch");
        uint256 sum;
        for (uint256 i = 0; i < fee.length; i++) {
            console.log(token[i], tokenAdd[tokenId[i]]);
            require(token[i] == tokenAdd[tokenId[i]], "token address error");
            if (token[i] == address(0)) {
                sum = sum.add(fee[i]);
            } else {
                IERC20(token[i]).transferFrom(
                    msg.sender,
                    address(this),
                    fee[i]
                );
            }
        }
        require(sum <= msg.value, "payable number error");

        emit DepositFee(fee, tokenId, token);
    }

    function claim(
        address token,
        address payable account,
        uint256 number,
        uint256 nonce,
        bool originalFlag,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public noReentrant {
        require(
            verify(owner(), token, account, number, nonce, r, s, v),
            "Wrong Signature"
        );

        require(
            account == msg.sender &&
                number > uint256(0) &&
                nonce > _nonce[account][token]
        );
        if (originalFlag) {
            require(token == address(0), "token address wrong");
            account.transfer(number);
        } else {
            _doTransferOutToken(token, account, number);
        }

        _nonce[account][token]++;
        emit Claim(token, account, number);
    }

    function _doTransferOutToken(
        address token,
        address _to,
        uint256 _amount
    ) internal {
        IERC20(token).transfer(_to, _amount);
        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                success := not(0)
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0)
            }
            default {
                revert(0, 0)
            }
        }
        require(success, "dotransferOut failure");
    }

    function setURI(string memory _newURI) public onlyOwner {
        _setURI(_newURI);
        emit SetURI(_msgSender(), _newURI);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function exists(uint256 _id) external view returns (bool) {
        return _exists(_id);
    }
}
