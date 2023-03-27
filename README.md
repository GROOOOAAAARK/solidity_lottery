# Solidity Lottery

This project demonstrates a basic lottery use case implemented with Solidity.

## Features

- [x] Allow users to buy lottery tickets by sending ether to the contract.
- [x] Once a certain number of tickets have been sold, the contract should pick a random winner and transfer the prize money to them.
- [x] The contract should prevent users from buying more tickets than the maximum allowed.
- [x] The contract should prevent users from buying tickets after the lottery has closed.
- [x] The contract should allow the contract owner to set the maximum number of tickets allowed and the prize amount.

## OPTIONAL features

- [x] A mechanism that allows an external app to live display the status of the lottery (by pushing events for instance)
- [] Anything you want if it does not take too much of your time

## Upgrades

- [] Better randomness using [Chainlink VRF](https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number)
- [] Allow users to buy multiple tickets at the same time

## How to use

- After deploying the contract (with a price in ETH for each ticket and a max number of tickets), the lottery is labeled as `Initialized`, the owner can start the lottery by calling the `startLottery` function. It will confirm parameters and allow users to buy tickets.
- Each ticket can be bought separately by using the `buyTicket` function. It will transfer the price of the ticket to the contract and emit an event.
- Once the last ticket is bought, the lottery is labeled as `Ended` and the winner is automatically picked. The total pool prize is then transferred to the winner.
- The owner can call the `resetLottery` function to reset the lottery and start a new one using the same contract, using a new ticket price and a new max number of tickets.
