//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Ownable.sol";
import "./interface/IERC20.sol";
import "./interface/Counters.sol";
import "hardhat/console.sol";

contract NFTMINT is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    address public token;
    uint256 private nonce;
    mapping(uint256 => uint256) private price;
    uint256 constant customGasLimit = 0.03 * 1e18; //800
    uint256 constant buyRandomCommercialCity = 800 * 1e8;
    uint256 constant buySpecifyCommercialCity = 1000 * 1e8;
    uint256 constant buyRandomUpgradeCommercialCity = 1300 * 1e8;
    uint256 constant buySpecifyUpgradeCommercialCity = 1500 * 1e8;
    uint256 constant buyRandomWorldMap = 200 * 1e8;
    uint256 constant buySpecifyWorldMap = 400 * 1e8;
    uint256 constant buyRandomUpgradeWorldMap = 700 * 1e8;
    uint256 constant buySpecifyUpgradeWorldMap = 900 * 1e8;
    string public baseExtension = ".json";
    string public baseURI;
    string _initBaseURI = "https://metadata.x-protocol.com/csfc/";
    Counters.Counter private currentTokenId;
    mapping(uint256 => string) private _tokenURIs;
    bool private _notEntered = true;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            )
        );
    bytes32 public constant BUYCOMMERCIALCITY_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "BuyCommercialCity(uint256 buy_way,uint256 hpn,uint256 vpn,uint256 horizontal,uint256 vertical,address account,uint256 nonce)"
            )
        );
    bytes32 public constant BuyWORLDMAP_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "BuyWorldMap(uint256 buy_way,uint256 hpn,uint256 vpn,uint256 horizontal,uint256 vertical,address account,uint256 nonce)"
            )
        );
    bytes32 public constant BUYOPENSEA_TRANSACTION_TYPEHASH =
        keccak256(
            bytes("BuyOpenSea(uint256 tokenid,address account,uint256 nonce)")
        );

    event BuyCommercialCity(
        address account,
        uint256 buyway,
        uint8 hpn,
        uint8 vpn,
        uint256 horizontal,
        uint256 vertical,
        uint256 _nonce,
        uint256 tokenid
    );
    event BuyWorldMap(
        address account,
        uint256 buyway,
        uint8 hpn,
        uint8 vpn,
        uint256 horizontal,
        uint256 vertical,
        uint256 _nonce,
        uint256 tokenid
    );
    event BuyOpenSea(address account, uint256 way, uint256 tokenid);
    event ClaimPot(address account, uint256 number);
    event ClaimEth(address account, uint256 number);
    event LockToken(address indexed account, uint256[] tokenId);
    event UnLockToken(address indexed account, uint256[] tokenId);

    constructor(address _token) ERC721("MINT NFT", "MINT") {
        setBaseURI(_initBaseURI);
        price[0] = buyRandomCommercialCity;
        price[1] = buySpecifyCommercialCity;
        price[2] = buyRandomUpgradeCommercialCity;
        price[3] = buySpecifyUpgradeCommercialCity;
        price[4] = buyRandomWorldMap;
        price[5] = buySpecifyWorldMap;
        price[6] = buyRandomUpgradeWorldMap;
        price[7] = buySpecifyUpgradeWorldMap;
        token = _token;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("NftMint")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }

    function nonceOf() public view returns (uint256) {
        return nonce;
    }

    function lock(uint256[] memory tokenIds) public {
        for (uint256 _i = 0; _i < tokenIds.length; _i++) {
            uint256 tokenId = tokenIds[_i];
            require(_checkNftOwner(tokenId) && !nftLock[tokenId]);

            nftLock[tokenId] = true;
        }
        emit LockToken(msg.sender, tokenIds);
    }

    function unlock(uint256[] memory tokenIds) public {
        for (uint256 _i = 0; _i < tokenIds.length; _i++) {
            uint256 tokenId = tokenIds[_i];
            require(_checkNftOwner(tokenId) && nftLock[tokenId]);

            nftLock[tokenId] = false;
        }
        emit UnLockToken(msg.sender, tokenIds);
    }

    function _checkNftOwner(uint256 tokenId) internal view returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return owner == msg.sender;
    }

    function buyCommercialCity(
        uint256 way,
        uint8 hpn,
        uint8 vpn,
        uint256 horizontal,
        uint256 vertical,
        address account,
        uint256 _nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable nonReentrant {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BUYCOMMERCIALCITY_TRANSACTION_TYPEHASH,
                        way,
                        hpn,
                        vpn,
                        horizontal,
                        vertical,
                        account,
                        _nonce
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress == owner() &&
                account == msg.sender &&
                _nonce > nonce
        );
        nonce++;
        _diff_transfer(0, way);
        uint256 new_tokenid = _mint(account);
        // string memory _horizontal = _change(hpn, horizontal);
        // string memory _vertical = _change(vpn, vertical);
        emit BuyCommercialCity(
            msg.sender,
            way,
            hpn,
            vpn,
            horizontal,
            vertical,
            _nonce,
            new_tokenid
        );
    }

    function buyWorldMap(
        uint256 way,
        uint8 hpn,
        uint8 vpn,
        uint256 horizontal,
        uint256 vertical,
        address account,
        uint256 _nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable nonReentrant {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BuyWORLDMAP_TRANSACTION_TYPEHASH,
                        way,
                        hpn,
                        vpn,
                        horizontal,
                        vertical,
                        account,
                        _nonce
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress == owner() &&
                account == msg.sender &&
                _nonce > nonce
        );
        // require(msg.value >= customGasLimit, "Not enough gas fee");
        nonce++;

        require(way >= 0 && way < 8, "wrong num");
        _diff_transfer(1, way);
        uint256 new_tokenid = _mint(account);

        // string memory _horizontal = _change(hpn, horizontal);
        // string memory _vertical = _change(vpn, vertical);
        emit BuyWorldMap(
            msg.sender,
            way,
            hpn,
            vpn,
            horizontal,
            vertical,
            _nonce,
            new_tokenid
        );
    }

    function buyOpenSea(
        uint256 way,
        uint256 tokenid,
        address account,
        uint256 _nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable nonReentrant {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        BUYOPENSEA_TRANSACTION_TYPEHASH,
                        tokenid,
                        account,
                        _nonce
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress == owner() &&
                account == msg.sender &&
                _nonce > nonce
        );
        nonce++;
        require(way >= 0 && way < 8, "wrong num");
        require(msg.value >= customGasLimit, "Not enough gas fee");
        _inter_transfer(price[way]);
        emit BuyOpenSea(msg.sender, way, tokenid);
    }

    function _diff_transfer(uint256 _buyWay, uint256 way) internal {
        if (_buyWay == 0) {
            require(way <= 3, "wrong num");
            _inter_transfer(price[way]);
        } else if (_buyWay == 1) {
            require(way >= 4, "wrong num");
            _inter_transfer(price[way]);
        }
    }

    function _inter_transfer(uint256 amount) internal {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function claim_eth(address payable account, uint256 number)
        public
        onlyOwner
    {
        account.transfer(number);
        emit ClaimEth(account, number);
    }

    function claim_pot(uint256 number) public onlyOwner {
        IERC20(token).transfer(msg.sender, number);
        emit ClaimPot(msg.sender, number);
    }

    function _mint(address recipient) internal returns (uint256) {
        currentTokenId.increment();
        // require(total >= currentTokenId._value, "Exceed the levy limit");
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent NFT"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // function _change(uint256 pn, uint256 num)
    //     internal
    //     pure
    //     returns (string memory _c)
    // {
    //     if (pn == 0) {
    //         string memory _a = toString(num);
    //         return _a;
    //     } else if (pn == 1) {
    //         string memory _a = "-";
    //         string memory _b = toString(num);
    //         string memory _c = strConcat(_a, _b);
    //         return _c;
    //     }
    // }

    // function strConcat(string memory _a, string memory _b)
    //     internal
    //     pure
    //     returns (string memory _c)
    // {
    //     bytes memory _ba = bytes(_a);
    //     bytes memory _bb = bytes(_b);
    //     string memory ret = new string(_ba.length + _bb.length);
    //     bytes memory bret = bytes(ret);
    //     uint256 k = 0;
    //     for (uint256 i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
    //     for (uint256 i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
    //     return string(ret);
    // }

    // function toString(uint256 value) internal pure returns (string memory) {
    //     if (value == 0) {
    //         return "0";
    //     }
    //     uint256 temp = value;
    //     uint256 digits;
    //     while (temp != 0) {
    //         digits++;
    //         temp /= 10;
    //     }
    //     bytes memory buffer = new bytes(digits);
    //     while (value != 0) {
    //         digits -= 1;
    //         buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
    //         value /= 10;
    //     }
    //     return string(buffer);
    // }
}
