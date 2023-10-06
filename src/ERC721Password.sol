// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";

abstract contract ERC721Password is ERC721 {
    // id => password hash
    mapping(uint => bytes32) public locks;
    // id => timestamp
    mapping(uint => uint) public force_unlock;

    event Locked(uint indexed id, address indexed owner, bytes32 password);
    event Unlocked(uint indexed id, address indexed owner);
    event StartForceUnlock(uint indexed id, address indexed owner, uint unlockTime);
    event CompleteForceUnlock(uint indexed id, address indexed owner);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function lock(uint id, bytes32 password) external {
        require(msg.sender == _ownerOf[id], "NOT_AUTHORIZED");
        require(locks[id] == 0x0, "ALREADY_LOCKED");
    
        locks[id] = password;

        emit Locked(id, msg.sender, password);
    }

    function unlock(uint id, bytes calldata plaintext) external {
        // should the approved person also be allowed to unlock it?
        require(msg.sender == _ownerOf[id], "NOT_AUTHORIZED");
        require(locks[id] == keccak256(plaintext), "WRONG_PASSWORD");

        locks[id] = 0x0;

        emit Unlocked(id, msg.sender);
    }

    function start_force_unlock(uint id) external {
        require(msg.sender == _ownerOf[id], "NOT_AUTHORIZED");

        force_unlock[id] = block.timestamp + 2 days;

        emit StartForceUnlock(id, msg.sender, block.timestamp + 2 days);
    }

    function complete_force_unlock(uint id) external {
        require(msg.sender == _ownerOf[id], "NOT_AUTHORIZED");
        uint force_unlock_time = force_unlock[id];
        // need to check > 0 otherwise you can always execute force unlock because of the zero-value
        require(force_unlock_time > 0 && force_unlock_time < block.timestamp, "NOT_READY");

        force_unlock[id] = 0;
        locks[id] = 0x0;
    
        emit CompleteForceUnlock(id, msg.sender);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(locks[id] == 0x0, "LOCKED");

        // reset everything before we transfer the token 
        force_unlock[id] = 0;

        super.transferFrom(from, to, id);
    }

    function _burn(uint256 id) internal override {
        require(locks[id] == 0x0, "LOCKED");
        // reset everything before we transfer the token 
        force_unlock[id] = 0;
        super._burn(id);
    } 
}