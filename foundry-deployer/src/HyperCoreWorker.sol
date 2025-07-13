// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import the L1Read contract
import "../precompiles/L1Read.sol";
import "../precompiles/CoreWriter.sol";

contract HyperCoreWorker is L1Read {
    
    event Action(address indexed user, bytes data);

    function sendAction(bytes calldata data) external {
        // Spends ~20k gas
        for (uint256 i = 0; i < 400; i++) {}
        emit Action(msg.sender, data);
    }

}