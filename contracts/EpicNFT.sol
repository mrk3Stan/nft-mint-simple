// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract EpicNFT is ERC721URIStorage {
    // to keep track off tokenIds
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;

    uint256 maxMintedNft = 1000;

    // this is our SVG code.
    // All changes is in the word that's displayed.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string baseSvg2 = "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // three arrays, each with their own words
    string[] firstWords = ["Black", "White", "Red", "Blue", "Green", "Yellow", "Pink", "Brown"];
    string[] secondWords = ["Brave", "Scared", "Cute", "Awesome", "Foolish", "Genious", "Sexy", "Epic"];
    string[] thirdWords = ["Dragon", "Cat", "Lion", "Dog", "Tiger", "Bear", "Butterfly", "Hamster"];
    
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("EpicNFT", "EPIC") {
        console.log("Epic NFT contract!");
    }

    function pickRandomFirstWord(uint256 tokenId) private view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // squash the # between 0 and number of array
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) private view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) private view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeEpicNFT() public {
        require(maxMintedNft > _tokenIds.current(), "1000 NFT has been minted.");
        // get current tokenId, this starts at zero
        uint256 newItemId = _tokenIds.current();

        // grab one word from each array
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // concatenate all together
        string memory finalSvg = string(abi.encodePacked(baseSvg, first, baseSvg2, combinedWord, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                // We set the title of our NFT as the generated word.
                combinedWord,
                '", "description": "A highly acclaimed collection.", "image": "data:image/svg+xml;base64,',
                // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                Base64.encode(bytes(finalSvg)),
                '"}'
            )
        );

        // prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n----------------");
        console.log(finalTokenUri);
        console.log("\n----------------");

        // mint the NFT to the sender
        _safeMint(msg.sender, newItemId);

        // set NFT data
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log("An NFT with ID %s has been minted to %s", newItemId, msg.sender);

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }

    function getTotalMintedNft() external view returns (uint256) {
        return _tokenIds.current() + 1;
    }
}