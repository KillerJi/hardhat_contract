// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "hardhat/console.sol";

contract EtherStore {
    mapping(address => uint256) public balances;

    fallback() external {
        console.log("2222");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(address payable abc) public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);
        console.log(bal);
        // (bool sent, ) = msg.sender.call{value: bal}("");
        // require(sent, "Failed to send Ether");
        abc.transfer(bal);
        uint256 bal1 = balances[msg.sender];
        console.log(bal1);
        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
