// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Access denied");
        _;
    }

    constructor() ERC20("Token B", "TKB") {
        owner = msg.sender;
    }

    function mint (uint amount) external onlyOwner {
        _mint(msg.sender, amount);
    }
}
