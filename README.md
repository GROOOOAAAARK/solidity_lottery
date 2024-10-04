# Solidity Lottery

This project demonstrates a basic lottery use case implemented with Solidity. Now with **foundry** ✅

## Features

- [x] Allow users to buy lottery tickets by sending ether to the contract.
- [x] Once a certain number of tickets have been sold, the contract should pick a random winner and transfer the prize money to them.
- [x] The contract should prevent users from buying more tickets than the maximum allowed.
- [x] The contract should prevent users from buying tickets after the lottery has closed.
- [x] The contract should allow the contract owner to set the maximum number of tickets allowed and the prize amount.
- [x] A mechanism that allows an external app to live display the status of the lottery (by pushing events for instance)

## Upgrades

- [ ] Better randomness using [Chainlink VRF](https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number)
- [ ] Allow users to buy multiple tickets at the same time
- [ ] fallback / receive functions

## How to use

- After deploying the contract (with a price in ETH for each ticket and a max number of tickets), the lottery is labeled as `Initialized`, the owner can start the lottery by calling the `startLottery` function. It will confirm parameters and allow users to buy tickets.
- Each ticket can be bought separately by using the `buyTicket` function. It will transfer the price of the ticket to the contract and emit an event.
- Once the last ticket is bought, the lottery is labeled as `Ended` and the winner is automatically picked. The total pool prize is then transferred to the winner.
- The owner can call the `resetLottery` function to reset the lottery and start a new one using the same contract, using a new ticket price and a new max number of tickets.

## Local tests (Foundry)

### Deployment

1. Source the env file with the needed vars
2. Run `anvil` to start the local blockchain environment
3. Create a `deployer` account with `cast wallet import deployer --interactive` and file in the private key of an already funded account.
4. Run `forge create ./src/Lottery.sol:Lottery --rpc-url $RPC_URL --account deployer --constructor-args $WEI_TICKET_PRICE --constructor-args $MAX_TICKET_NB`

The contract is now deployed ! 🚀
