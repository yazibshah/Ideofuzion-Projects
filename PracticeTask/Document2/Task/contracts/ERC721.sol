// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Doblier is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 public maxSupply=5;

    bool public publicMintOpen=false;
    bool public allowMintOpen=false; 


    // Allow List addres will be allowed to get Public mint access
    mapping(address=> bool) public allowList; 

    constructor()
        ERC721("Doblier", "DOB")
        Ownable(msg.sender)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://cdn.galxe.com/galaxy/arbitrum/89b2507d-2994-4748-b1a0-1ba3718a8cd7.jpeg";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    // Public and Allow list Mint open
    function editMintWindows(bool _publicMintOpen,bool _allowMintOpen) external onlyOwner{
        publicMintOpen=_publicMintOpen;
        allowMintOpen=_allowMintOpen;

    }

    
    // Allow List Mint
    function allowListMint() public payable{
        require(allowMintOpen,"Allow List Mint closed");
        require(allowList[msg.sender],"you are not on the Allow List");
        require(msg.value==0.001 ether,"not Enough Fund");
        internalMint();
    }
    // Add Payment
    function publicMint() public payable {
        require(publicMintOpen,"Public  Mint closed");
        require(msg.value==0.01 ether,"Not Enough Fund.");
        internalMint();
    }

    // Internal Mint
    function internalMint() internal {
         require(totalSupply()<maxSupply,"We sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    // Set Allow List
    function setAllowLst(address[] calldata addresses )  external onlyOwner{
        for(uint256 i=0;i< addresses.length;i++) {
            allowList[addresses[i]]=true;
        }
    }   

    // WithDraw All amount Of Smart Contract
    function withDraw(address _addr) external onlyOwner{
        uint256 balance=address(this).balance;
        payable(_addr).transfer(balance);
    }
    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}