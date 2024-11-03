// Create Raffle Contract
// Enter the lottery (pay some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keeper)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/* Errors */
error Raffle__NotEnoughEthEntered();

contract Raffle {
    uint256 private immutable i_entranceFee;

    // keep track of the players enter the raffle
    address payable[] private s_players; // when a player wins, we want to pay them so we make it payable

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    //! Create Raffle Contract
    function enterRaffle() public payable {
        // require msg.value < i_entranceFee;
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthEntered();
        }
        
        s_players.push(payable(msg.sender)); // must be payable, because s_players is a payable array
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
    
    function getPlayer(uint256 index) public view returns (address) {
        retrn s_players[index];
    }
}
