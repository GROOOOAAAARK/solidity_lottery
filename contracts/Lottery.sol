//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

//* @title Lottery
//* @author Thomas Lenoir
//* @dev This contract is a simple implementation of a lottery game
//* @notice This contract is not meant to be used in production
contract Lottery is Ownable {

    enum LotteryState {
        Initialized,
        Started,
        Ended
    }

    uint256 private _ticketPrice;
    uint256 private _maxTicketCount;
    uint256 private _ticketsSold;

    address[] private _participants;

    LotteryState private _lotteryState;

    event LotteryStarted(uint256 ticketPrice, uint256 ticketCount);

    event LotteryEnded(address winner);

    event TicketBought(address buyer, uint256 ticketPrice);

    modifier costs(uint256 amount) {
        require(msg.value / 1 ether == amount, "Lottery: invalid ticket price");
        _;
    }

    modifier isLotteryInitialized() {
        require(_lotteryState == LotteryState.Initialized, "Lottery: already started or ended");
        _;
    }

    modifier isLotteryOngoing() {
        require(_lotteryState == LotteryState.Started, "Lottery: not started or ended");
        _;
    }

    constructor(
        uint256 price,
        uint256 ticketCount
    ) Ownable() {
        _ticketPrice = price;
        _maxTicketCount = ticketCount;
        _lotteryState = LotteryState.Initialized;
    }

    //* @dev Start the lottery. Use this function to start the lottery after the initialization
    function startLottery() external isLotteryInitialized onlyOwner {
        _lotteryState = LotteryState.Started;
        emit LotteryStarted(_ticketPrice, _maxTicketCount);
    }

    //* @dev Reset a new lottery if the current one has ended and the funds have been transferred to the winner
    function resetLottery(
        uint256 newTicketPrice,
        uint256 newMaxTicketCount
    ) external onlyOwner {
        require(_lotteryState == LotteryState.Ended, "Lottery: not ended");
        _ticketPrice = newTicketPrice;
        _maxTicketCount = newMaxTicketCount;
        _ticketsSold = 0;
        _participants = new address[](0);
        _lotteryState = LotteryState.Initialized;
    }

    //* @dev Buy a ticket. You must send the exact ticket price to the contract
    function buyTicket() external payable isLotteryOngoing costs(_ticketPrice) {
        _participants.push(msg.sender);
        _ticketsSold++;

        emit TicketBought(msg.sender, msg.value);

        if (_ticketsSold == _maxTicketCount) {
            _endLottery();
        }
    }

    //* @dev End the lottery and transfer the funds to the winner
    function _endLottery() private {
        require(_lotteryState == LotteryState.Started, "Lottery: not started");
        require(_ticketsSold == _maxTicketCount, "Lottery: not enough tickets sold");
        _lotteryState = LotteryState.Ended;
        address winner = _getRandomWinner();
        payable(winner).transfer(address(this).balance);
        emit LotteryEnded(winner);
    }

    //* @dev Get random winner from list of participants
    function _getRandomWinner() internal view returns (address) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, _participants)));
        return _participants[random % _participants.length];
    }

    //* @dev Update price
    function setPrice(uint256 newPrice) external isLotteryInitialized onlyOwner {
        _ticketPrice = newPrice;
    }

    //* @dev Update max ticket count
    function setMaxTicketCount(uint256 newMaxTicketCount) external isLotteryInitialized onlyOwner {
        _maxTicketCount = newMaxTicketCount;
    }

    //* @dev Get the current state of the lottery
    function state() external view returns (LotteryState) {
        return _lotteryState;
    }

    //* @dev Get the ticket price
    function ticketPrice() external view returns (uint256) {
        return _ticketPrice;
    }

    //* @dev Get the max number of tickets to be sold
    function maxTicketCount() external view returns (uint256) {
        return _maxTicketCount;
    }

    //* @dev Get the list of participants
    function participants() external view returns (address[] memory) {
        return _participants;
    }

    //* @dev Get the number of tickets sold
    function ticketsSold() external view returns (uint256) {
        return _ticketsSold;
    }

    //* @dev Get the number of tickets left
    function ticketsLeft() external view returns (uint256) {
        return _maxTicketCount - _ticketsSold;
    }

    //* @dev Get the total amount of funds in the contract
    function stakes() public view returns (uint256) {
        return _ticketsSold * _ticketPrice;
    }


}
