pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {MockERC721} from "solmate/test/utils/mocks/MockERC721.sol";
import {ERC721PwWrapper} from "../src/ERC721PwWrapper.sol";

contract ERC721PwTest is Test {
    MockERC721 underlying;
    ERC721PwWrapper token;
    function setUp() public {
        underlying = new MockERC721("Token", "TKN");
        token = new ERC721PwWrapper(address(underlying), "Pw Token", "Pw TKN");
    }

    function testPullsUnderlyingOnMint() public {
        underlying.mint(address(this), 1);
        underlying.approve(address(token), 1);

        token.mint(address(this), 1);

        assertEq(underlying.ownerOf(1), address(token));
        assertEq(token.ownerOf(1), address(this));
    }

    function testReturnsUnderlyingOnBurn() public {
        underlying.mint(address(this), 1);
        underlying.approve(address(token), 1);
        token.mint(address(this), 1); 

        token.burn(address(this), 1);

        assertEq(underlying.ownerOf(1), address(this));
        vm.expectRevert("NOT_MINTED");
        token.ownerOf(1);
    }

    function testCannotMintWithoutGivingUnderlying() public {
        underlying.mint(address(this), 1);

        vm.expectRevert("NOT_AUTHORIZED");
        token.mint(address(this), 1);
    }
}