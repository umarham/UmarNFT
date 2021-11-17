// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  
  string _baseTokenURI;
  uint256 public totalMinted = 0;
  uint256 public totalSupply = 50;
  uint256 internal _price = 0.01 ether;
  address public owner;
  mapping(uint256 => address) umarIndexToAddress;
  mapping (address => uint256) public _balanceOf;

  

  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] firstWords = ["Naruto", "Itachi", "Kazuto", "Kurisu", "Hachiman", "Rintarou"];
  string[] secondWords = ["Toothless", "Draco", "Askook", "Glaurung", "Nagendra", "Ryuu"];
  string[] thirdWords = ["Fantastic", "Epic", "Crazy", "Terrible", "Wild", "Spooky"];


  string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];


  event NewEpicNFTMinted(address _sender, uint256 _tokenId);

  constructor() ERC721 ("UmarNFT", "UMAR") {
    owner = msg.sender;
  }

  modifier OnlyOwner {
    require(msg.sender == owner, "Sender is not owner!");
    _;
  }

  function getTotalNFTMintedSoFar() public view returns (uint256) {
    return _tokenIds.current();
  }

  function getUserNFTMintedSoFar() public view returns (uint256) {
    return _balanceOf[msg.sender];
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function _setBaseTokenURI(string memory _uri) public OnlyOwner {
    _baseTokenURI = _uri;
  }
   
  function setPrice(uint256 _newPrice) public OnlyOwner {
    _price = _newPrice;
  }
  
  function getPrice() public view returns (uint256){
     return _price;
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    require(totalMinted < totalSupply, "The total number of NFTs have been minted");
    
    totalMinted = totalMinted + 1;

    uint256 newItemId = _tokenIds.current();

    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    string memory randomColor = pickRandomColor(newItemId);
    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));


    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "An NFT from the highly acclaimed square collection.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT with ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}