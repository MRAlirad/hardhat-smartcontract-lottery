# Hardhat Smartcontract Lottery

## Hardhat Setup

as you know you should install and initialize hardhat and create a hardhat.config.js file.

```bash 
yarn add --save-dev hardhat
yarn hardhat init
```

## Raffle.sol Setup

- [`Custom Errors in Solidity`](https://soliditylang.org/blog/2021/04/21/custom-errors/)

## Introduction to Events

whenever we update a dynamic object in solidity we can emit an event to notify the client.

`EVM` can emit logs

### Logs

it is possible to store data in a specially indexed data structure that maps all the way up to the block level. This feature called `logs` is used by Solidity in order to implement `events`. Contracts cannot access log data after it has been created. but they can be efficiently accessed from outsidee of the blockchain. Since some part of the log data is stored in `bloom filters`, it is possible to search for thisdata in an efficient and cryptographically secure way, so network peers that do not download the whole blockchain (so called `light clients`) can still find these `logs`.

we can actually read these logs from our blockchain node that we run. in fact if we run a node or connect to a node you can make a `eth_getLogs` call to get the logs.

logs and events are often used `synonymously`.

Events aloow you to `print` stuff to this log.

Smart contracts can't access logs.

when we emit an event, there are two kinds of parameters. `indexed parameters` and `non-indexed parameters`.

#### Indexed Parameters

In Solidity, indexed parameters are a feature of events that allows for efficient filtering and searching of events by their values. When a parameter is marked as indexed, its value is stored separately from the event data, along with the event signature, in a special data structure called a “topic”. This enables fast lookup and filtering of events by their indexed values.

1. Limited to 3 indexed parameters: Solidity allows up to 3 parameters to be marked as indexed.
2. Only specific types: Only certain types, such as address, bytes32, bool, and uint256, can be used as indexed parameters.
3. Separate storage: Indexed parameters are stored separately from regular event data, in the topic structure.
4. Efficient filtering: Indexed parameters enable fast lookup and filtering of events by their values, using a binary search algorithm.

``` js
event Transfer(address indexed from, address indexed to, uint256 value);
```

##### Advantages of Indexed Parameters

1. Improved query performance: Indexed parameters enable fast lookup and filtering of events, reducing the computational overhead of querying large event logs.
2. Enhanced data retrieval: Indexed parameters provide a way to retrieve specific events based on their values, without having to scan the entire event log.


##### Best Practices of Indexed Parameters

1. Use indexed parameters judiciously: Only mark parameters as indexed if they are frequently used for filtering or querying.
2. Keep indexed parameters minimal: Limit the number of indexed parameters to 3, to avoid increased gas costs and complexity.
3. Ensure data formatting: Verify that the data types and formats of indexed parameters align with your application’s requirements.


#### Non-Indexed Event Parameters

In Solidity, non-indexed parameters in events are those that are not marked with the indexed keyword. When an event is emitted, non-indexed parameters are stored in the data part of the log entry, along with the event name and topics (which include the Keccak hash of the event signature and the indexed parameters).

##### key characteristics

1. ABI-encoded: Non-indexed parameters are ABI-encoded, which means they are serialized according to the ABI (Application Binary Interface) specification. This encoding is used to store the data in the log entry.
2. Harder to search: Because non-indexed parameters are ABI-encoded, they are more difficult to search for and filter compared to indexed parameters. To decode and retrieve the values of non-indexed parameters, you need to know the ABI of the contract.
3. Limited filtering: Non-indexed parameters cannot be used as filters in event queries. You cannot search for specific values of non-indexed parameters in the event logs.
4. Stored in data: Non-indexed parameters are stored in the data part of the log entry, along with the event name and topics.

``` sol
event MyEvent(uint256 nonIndexedValue, string nonIndexedString);
```

##### Use cases

1. You need to store additional data in the event log that is not important for filtering or querying.
2. You want to store complex data structures, such as structs or arrays, in the event log.
3. You need to store data that is not relevant to the filtering or querying of the event.

- [`events and logging in hardhat`](https://github.com/PatrickAlphaC/hardhat-events-logs)
- [`events and logging video`](https://www.youtube.com/watch?v=KDYJC85eS5M)

## Introduction to Chainlink VRF (Randomness in Web3)

- [Chainlink VRFv2 Docs](https://docs.chain.link/docs/get-a-random-number/)
- [Chainlink VRFv2 Walkthrough](https://www.youtube.com/watch?v=rdJ5d8j1RCg)
- [Chainlink Contracts](https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol)