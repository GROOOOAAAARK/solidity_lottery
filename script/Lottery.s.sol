// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Lottery } from "@contracts/Lottery.sol";

contract LotteryScript is Script {
    address lottery;

    function setUp() public {
        uint256 ticketPrice = 100;
        uint256 maxTicketCount = 10;

        vm.startBroadcast();
        Lottery lotteryContract = new Lottery(ticketPrice, maxTicketCount);

        lottery = address(lotteryContract);

        console.log("Lottery deployed at %s with %s tickets priced %s Wei each", lottery, maxTicketCount, ticketPrice);
    }

    function run() public {
        vm.broadcast();
    }
}
