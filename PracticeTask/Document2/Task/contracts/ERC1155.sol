// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";


contract Doblier1155 is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {

    uint256 constant public allowListPrice=1 ether;
    uint256 constant public publicPrice=2 ether;

    uint256 maxSupply=10;

    uint256 public maxPerWallet=3;
    
    bool public publicMintOpen=false;
    bool public allowListMintOpen=true;


    /* Allow List Mapping */
    mapping(address=>bool) allowList;

    /* Purchase Per Wallet */
    mapping(address => uint256) purchasePerWallet;

    constructor(
        address [] memory _payees,
        uint256[] memory _shares

    )
        ERC1155("https://ipfs.io/ipfs/QmfLUZzTVt3Z1mTruFr2PCgAirVLs2EHaa5uKD3GfbATfK")
        Ownable(msg.sender)
        PaymentSplitter(_payees,_shares)
    {}


    /* function for Editing Status of Minting  */
    function editMintWindows(bool _publicMintopen,bool _allowListMintOpen) external  onlyOwner{
          publicMintOpen=_publicMintopen;
         allowListMintOpen=_allowListMintOpen;
    }

    /* Create a Function to Set Allow List*/
    function setAllowList(address[] calldata addresess) external onlyOwner{
        for(uint256 i=0; i<addresess.length;i++){
            allowList[addresess[i]]=true;
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }



    /* Allow List Mint */
    function allowListMint(uint256 id,uint256 amount) public payable{
        require(allowListMintOpen,"Allow List Mint is Closed");
        require(allowList[msg.sender],"You are not on the Allow List");      
        require(msg.value==allowListPrice * amount,"Not Enough Amount");
        mint(id,amount);
        
    }

    /*  Add Supply Tracking */
    function PublicMint(uint256 id,uint256 amount) public payable{
        require(publicMintOpen,"Public List Mint is Closed");
        require(msg.value==publicPrice * amount,"Not Enough Amount");
        mint(id,amount);
        
    }
    
    /* Mint Function  */
    function mint(uint256 id,uint256 amount) internal {
        require(purchasePerWallet[msg.sender] +amount < maxPerWallet,"You Can't Mint more Then 3 NFT's");
        require(id < 2,"Sorry Looks Like Trying to mint Wrong NFT");
        require(totalSupply(id) + amount < maxSupply,"all are sold");
        _mint(msg.sender, id, amount,"");
        purchasePerWallet[msg.sender] +=amount;
    }


    /*  WithDraw All amount Of Smart Contract */
    function withDraw(address _addr) external onlyOwner{
        uint256 balance=address(this).balance;
        payable(_addr).transfer(balance);
    }
    /* URI Function */
     function uri(uint256  _id ) public view virtual override  returns (string memory) {
        require(exists(_id),"URI Non Existance Token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }


    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}

