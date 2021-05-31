// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    //minter variable
    address public minter;

    //minter changed event
    event MinterChanged(address indexed from, address to);

    constructor() public payable ERC20("Lugashs DBank Currency", "LDBC") {
        //asigning initial minter
        minter = msg.sender;
    }

    //pass minter role function
    function passMinterRole(address dBank) public returns (bool) {
        require(
            msg.sender == minter,
            "Error, only owner can change pass minter role"
        );
        minter = dBank;

        emit MinterChanged(msg.sender, dBank);
        return true;
    }

    function mint(address account, uint256 amount) public {
        //check if msg.sender have minter role
        require(
            msg.sender == minter,
            "Error, msg.sender doest not have minter role"
        );
        _mint(account, amount);
    }
}
