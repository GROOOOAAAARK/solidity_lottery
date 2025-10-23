//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@interfaces/ILottery.sol";

abstract contract ALottery is Ownable, ILottery {

    uint256 private _ticketPrice;
    uint256 private _maxTicketCount;
    uint256 private _ticketsSold;

    address[] private _participants;

    LotteryState private _lotteryState;

    event LotteryStarted(uint256 ticketPrice, uint256 ticketCount);

    event LotteryEnded(address winner);

    event TicketBought(address buyer, uint256 ticketPrice);

    constructor(
        uint256 price,
        uint256 ticketCount
    ) {
        _ticketPrice = price;
        _maxTicketCount = ticketCount;
        _lotteryState = LotteryState.Initialized;
    }

    function state() external view override returns (LotteryState) {
        return _lotteryState;
    }

    function startLottery() external override onlyOwner {
        require(_lotteryState == LotteryState.Initialized, "Lottery: already started");
        _lotteryState = LotteryState.Started;
    }

    function resetLottery(
        uint256 newTicketPrice,
        uint256 newMaxTicketCount
    ) external onlyOwner {
        require(_lotteryState == LotteryState.Ended, "Lottery: not ended");
        _ticketPrice = newTicketPrice;
        _maxTicketCount = newMaxTicketCount;
    }

    function ticketPrice() external view override returns (uint256) {
        return _ticketPrice;
    }

    function maxTicketCount() external view override returns (uint256) {
        return _maxTicketCount;
    }

    function participants() external view override returns (address[] memory) {
        return _participants;
    }

    function ticketsSold() external view override returns (uint256) {
        return _ticketsSold;
    }
}
