pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {MockERC721} from "solmate/test/utils/mocks/MockERC721.sol";

import {ERC721PwWrapperFactory} from "../src/ERC721PwWrapperFactory.sol";

contract ERC721PwWrapperFactoryTest is Test {
    ERC721PwWrapperFactory factory;
    function setUp() public {
        factory = new ERC721PwWrapperFactory();
    }

    function testDeploy() public {
        MockERC721 underlying = new MockERC721("Token", "TKN");

        address wrapper = factory.deployWrapper(address(underlying));

        assertEq(factory.wrappers(address(underlying)), wrapper);
    }

    function testCannotDeployTwice() public {
        MockERC721 underlying = new MockERC721("Token", "TKN");
        address wrapper = factory.deployWrapper(address(underlying));
        assertEq(factory.wrappers(address(underlying)), wrapper);

        vm.expectRevert("EXISTS");
        factory.deployWrapper(address(underlying)); 
    }
}