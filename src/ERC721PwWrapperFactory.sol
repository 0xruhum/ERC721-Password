// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC721PwWrapper} from "./ERC721PwWrapper.sol";

contract ERC721PwWrapperFactory {
   mapping(address => address) public wrappers; 

   function deployWrapper(address underlying) external returns (address wrapper) {
        require(wrappers[underlying] == address(0), "EXISTS");

        string memory name = ERC721(underlying).name();
        string memory symbol = ERC721(underlying).symbol();
        wrapper = address(new ERC721PwWrapper(underlying, name, symbol));

        wrappers[underlying] = wrapper;
   }
}