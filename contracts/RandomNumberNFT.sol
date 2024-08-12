// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { Base64 } from "./libraries/Base64.sol";

contract RandomNumber {
    function getRandomNumber(uint256 min, uint256 max)
        external
        view
        returns (uint256 ans)
    {
        require(max > min);

        ans =
            uint256(
                keccak256(
                    abi.encodePacked(min, max, block.timestamp, address(this))
                )
            ) %
            (max - min);
        ans += min;
    }
}

contract RandomNFT is Ownable, ERC721URIStorage {
    RandomNumber public rand;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event Minted(uint256 tokenId);

    constructor() ERC721("RandomNFT", "RNFT") {
        rand = new RandomNumber();
    }

    /* Generates a tokenURI using Base64 string as the image */
    function formatTokenURI(uint256 value) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Random NFT", "description": "Random NFT with random value attribute", "attributes":[{"trait_type":"Value","value":',
                                value,
                                "}]"
                            )
                        )
                    )
                )
            );
    }

    function mint() public onlyOwner {
        string memory tokenURI = formatTokenURI(rand.getRandomNumber(100, 500));

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit Minted(newItemId);
    }
}
