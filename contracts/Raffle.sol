// Create Raffle Contract
// Enter the lottery (pay some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keeper)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/* Errors */
error Raffle__NotEnoughEthEntered();

contract Raffle is VRFConsumerBaseV2 { // inherited from VRFConsumerBaseV2
    uint256 private immutable i_entranceFee;

    // keep track of the players enter the raffle
    address payable[] private s_players; // when a player wins, we want to pay them so we make it payable
    
    /** Events **/
    event RaffleEnter(address indexed player);

    constructor( address vrfCoordinatorV2,uint256 entranceFee) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
    }

    //! Create Raffle Contract
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthEntered(); // require msg.value < i_entranceFee;
        s_players.push(payable(msg.sender)); // must be payable, because s_players is a payable array
        emit RaffleEnter(msg.sender); // Named events with the function name reversed
    }
    
    function requestRandomWinner() external {
        // request the random number
        // once we get it, do something with it

        // 2 tranactions process
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        
    }

    /** View / Pure functions **/
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
