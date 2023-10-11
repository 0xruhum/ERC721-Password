// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721Pw} from "./ERC721Pw.sol";

/**
* @title Wrap existing ERC721s into ERC721Pw contracts
* @author Ruhum
*/
contract ERC721PwWrapper is ERC721Pw {
    IERC721 immutable underlying;
    constructor(address token, string memory _name, string memory _symbol) ERC721Pw (
        string.concat("Pw Protected: ", _name),
        string.concat("Pw: ", _symbol)
    ) {
        underlying = IERC721(token);
    }

    /// @dev expects the caller to have approved the underlying ERC721's token to be approved to this contract.
    /// @dev expects the caller to be able to handle the ERC721, i.e. doesn't use `safeMint()`
    /// @notice doesn't lock token automatically. Has to be done separately.
    function mint(address to, uint id) external {
        underlying.transferFrom(msg.sender, address(this), id);

        _mint(to, id);
    }

    /// @dev expects the caller to be able to handle ERC721 tokens.
    /// @notice will revert if token isn't unlocked
    function burn(address to, uint id) external {
        _burn(id);

        underlying.transferFrom(address(this), to, id);
    }

    function tokenURI(uint id) public view override returns (string memory) {
        return underlying.tokenURI(id);
    }
}

interface IERC721 {
    function transferFrom(address from, address to, uint id) external;
    function tokenURI(uint id) external view returns (string memory);
}