// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    event Minted(uint256 tokenId, address minter);

    mapping(address => uint[]) public ownerTokens;
    uint public maxSupply = 5;
    uint public totalSupply;

    constructor() ERC721("My NFT", "NFT") {}

    function ownerTokensLength(address _owner) external view returns(uint) {
        return ownerTokens[_owner].length;
    }

    // function mint() external payable {

    function mint() external {
        // msg.value
        require(totalSupply < maxSupply, "max supply reached");

        uint tokenId = ++totalSupply;
        _safeMint(msg.sender, tokenId);
        ownerTokens[msg.sender].push(tokenId);

        emit Minted(tokenId, msg.sender);
    }

    function _baseURI() internal pure override virtual returns(string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmcjmAxS553kvXtFCUPX7f3FN3gUH6y2yHWnFgfB2qvpdZ/";
    }
 
}