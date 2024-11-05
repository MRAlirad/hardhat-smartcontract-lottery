// Create Raffle Contract
// Enter the lottery (pay some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -> completely automated
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keeper)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

/* Errors */
error Raffle__NotEnoughEthEntered();
error Raffle__RaffleNotOpen();
error Raffle__TransferFailed();

// inherited from VRFConsumerBaseV2
contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    /**  Type Declarations **/
    enum RaffleState {
        OPEN,
        CALCULATING
    } // 0 = open, 1 = calculating

    /** State Variables **/
    uint256 private immutable i_entranceFee;
    address payable[] private s_players; // keep track of the players enter the raffle - when a player wins, we want to pay them so we make it payable
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    /** Lottery Variables **/
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval; // how long we want to wait before picking a winner

    /** Events **/
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    //! Create Raffle Contract
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthEntered(); // require msg.value < i_entranceFee;
        if (s_raffleState != RaffleState.OPEN) revert Raffle__RaffleNotOpen(); // require(s_raffleState == RaffleState.OPEN, "Raffle is not open");
        s_players.push(payable(msg.sender)); // must be payable, because s_players is a payable array
        emit RaffleEnter(msg.sender); // Named events with the function name reversed
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    function checkUpkeep(bytes memory /* checkData */) external override returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool isOpen = (RaffleState.OPEN == s_raffleState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        
        // if true, request a random number and end the lottory
    }

    function requestRandomWinner() external {
        // change state to be calculating so noone can enter the raffle
        s_raffleState = RaffleState.CALCULATING;

        // request the random number
        // once we get it, do something with it
        // 2 tranactions process
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /* requestId */, // requestId is not needed
        uint256[] memory randomWords
    ) internal override {
        // once we get the random number, we want to pick a random winner from our players array

        // pick a random winner from sth called `modulo`
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN; // change state to be open

        s_players = new address payable[](0); // reset the players array

        // Send money
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) revert Raffle__TransferFailed();
        emit WinnerPicked(recentWinner);
    }

    /** View / Pure functions **/
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
