pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {MockERC721Pw} from "./MockERC721Pw.sol";

contract ERC721PwTest is Test {
    MockERC721Pw token;
    function setUp() public {
        token = new MockERC721Pw("Token", "TKN");
    }

    function testOwnerCanLock() public {
        token.mint(address(this), 1);

        token.lock(1, keccak256("password"));
        assertEq(token.locks(1), keccak256("password"));
    }

    function testCannotTransferIfLocked() public {
        token.mint(address(this), 1);

        token.lock(1, keccak256("password"));

        vm.expectRevert("LOCKED");
        token.transferFrom(address(this), vm.addr(2), 1);
    }

    function testOnlyOwnerCanLock() public {
        token.mint(vm.addr(2), 1);

        vm.expectRevert("NOT_AUTHORIZED");
        token.lock(2, keccak256("password"));
    }

    function testUnlock() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));

        token.unlock(1, "password");
        assertEq(token.locks(1), 0x0);
    }

    function testOnlyOwnerCanUnlock() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));

        vm.expectRevert("NOT_AUTHORIZED");
        vm.prank(vm.addr(2));
        token.unlock(1, "password");
    }

    function testCannotForceUnlockImmediately() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));

        vm.expectRevert("NOT_READY");
        token.complete_force_unlock(1);
    }

    function testCannotForceUnlockEarly() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));
        token.start_force_unlock(1);
    
        vm.warp(block.timestamp + 2 days);
    
        vm.expectRevert("NOT_READY");
        token.complete_force_unlock(1);
    }

    function testOnlyOwnerCanInitiateForceUnlock() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));
        vm.prank(vm.addr(2));
        vm.expectRevert("NOT_AUTHORIZED");
        token.start_force_unlock(1);
    }

    function testOnlyOwnerCanCompleteForceUnlock() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));
        token.start_force_unlock(1);
    
        vm.warp(block.timestamp + 2 days + 1);
        
        vm.prank(vm.addr(2));
        vm.expectRevert("NOT_AUTHORIZED");
        token.complete_force_unlock(1);
    }

    function testForceUnlock() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));
        token.start_force_unlock(1);
    
        vm.warp(block.timestamp + 2 days + 1);
        
        token.complete_force_unlock(1);

        assertEq(token.locks(1), 0x0);
    }


    function testResetForceUnlockOnTransfer() public {
        token.mint(address(this), 1);
        token.lock(1, keccak256("password"));
        token.start_force_unlock(1);
        assertEq(token.force_unlock(1), block.timestamp + 2 days);
        token.unlock(1, "password");
        token.transferFrom(address(this), vm.addr(2), 1);

        assertEq(token.force_unlock(1), 0);
    }
}