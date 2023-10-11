// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721Pw} from "../src/ERC721Pw.sol";

contract MockERC721Pw is ERC721Pw {
    constructor(string memory _name, string memory _symbol) ERC721Pw(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }
}