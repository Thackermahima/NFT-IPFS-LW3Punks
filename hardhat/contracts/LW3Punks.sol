// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LW3Punks is ERC721Enumerable,Ownable{

  using Strings for uint256;
  //Resulting URI for each token will be concatenation of the baseURI and tokenId. 
  string _baseTokenURI;

  //Price is of one LW3Punks.
  uint256 public _price = 0.01 ether;

  //Paused is used to pause the contract incase of an emergency.
  bool public _paused;

  //Max number of LW3Punks
  uint256 public maxTokenIds = 10;
  
  //total number of tokenIds minted.
  uint256 public tokenIds;
  
  modifier onlyWhenNotPaused{
    require(!_paused, "Contract currently paused");
    _;
  }
  constructor(string memory baseURI)ERC721("LW3Punks","LW3P"){
  _baseTokenURI = baseURI;
  }

  //Mint allows an user to mint an NFT per transaction.
  function mint()public payable onlyWhenNotPaused{
  require(tokenIds < maxTokenIds,"Exceed maximum LW3Punks supply");
  require(msg.value >= _price,"Ether price is not correct");
  tokenIds += 1;
  _safeMint(msg.sender, tokenIds);
  }
  /* _baseURI() function overrides openzeppelin contract's function 
  and returns _baseTokenURI.
  */
  function _baseURI() internal view virtual override returns(string memory){
    return _baseTokenURI;
  }
  function tokenURI(uint256 tokenId)public view virtual override returns(string memory){
   require(_exists(tokenId),"ERC721Metadata: URI query for nonExistence token");
   string memory baseURI = _baseURI();

   /*Here if length of a baseURI is greater than 0, it returns json data else if will return blank */
   return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
  }
  function setPaused(bool val)public onlyOwner{
       _paused = val;
  }
 // Withdraw function sends all the ether in the contract to the owner of the contract. 
  function withdraw()public onlyOwner{
   address _owner = owner();
   uint256 amount = address(this).balance;
   (bool sent, ) = _owner.call{value : amount}("");
   require(sent, "Failed to send Ether");
  }

  //Function to receive Ether, msg.data must be empty.
  receive() external payable{}

  //fallback function is called when msg.data is not empty.
  fallback() external payable{}
  
}