//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./interface/Counters.sol";

contract Greeter is ERC721, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private currentTokenId;
    uint256 public total;
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("POTName", "POT") {
        total = 100;
    }

    function mintTo(address recipient) public returns (uint256) {
        currentTokenId.increment();
        require(total >= currentTokenId._value, "Exceed the levy limit");
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }
}
