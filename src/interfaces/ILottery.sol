//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

//* @title Lottery
//* @author Thomas Lenoir
//* @dev This contract is a simple implementation of a lottery game
//* @notice This contract is not meant to be used in production
interface ILottery {

    enum LotteryState {
        Initialized,
        Started,
        Ended
    }

    //* @dev Get the current state of the lottery
    function state() external view returns (LotteryState);

    //* @dev Start the lottery
    function startLottery() external;

    //* @dev Reset a new lottery
    function resetLottery() external;

    //* @dev Buy a ticket.
    //* @notice You must send the exact ticket price to the contract
    function buyTicket() external payable;

    //* @dev Get the ticket price
    function ticketPrice() external view returns (uint256);

    //* @dev Get the max number of tickets to be sold
    function maxTicketCount() external view returns (uint256);

    //* @dev Get the list of participants
    function participants() external view returns (address[] memory);

    //* @dev Get the number of tickets sold
    function ticketsSold() external view returns (uint256);
}