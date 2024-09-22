// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Lottery } from "@contracts/Lottery.sol";

contract LotteryDeployLocal is Script {
    address payable _lotteryAddress;
    uint256 _ticketPrice;
    uint256 _maxTicketCount;

    function setUp() public {
        _ticketPrice = 100;
        _maxTicketCount = 10;

        vm.startBroadcast();

        _lotteryAddress = _deploy(_ticketPrice, _maxTicketCount);

        console.log("Lottery deployed at %s with %s tickets priced %s Wei each", _lotteryAddress, _maxTicketCount, _ticketPrice);
    }

    function _deploy(uint256 ticketPrice, uint256 maxTicketCount) public returns (address payable lotteryAddress) {
        Lottery lotteryContract = new Lottery(ticketPrice, maxTicketCount);

        lotteryAddress = payable(address(lotteryContract));
    }

    //@ dev Checks that contract parameters are set correctly
    function testParametersAreSet() public {
        Lottery lotteryContract = Lottery(_lotteryAddress);
        assert(lotteryContract.ticketPrice() == _ticketPrice);
        assert(lotteryContract.maxTicketCount() == _maxTicketCount);
    }

    //@ dev Checks that the contract is in the correct state
    function testContractIsInCorrectState() public {
        Lottery lotteryContract = Lottery(_lotteryAddress);
        assert(lotteryContract.state() == Lottery.State.Initialized);
    }

    // @dev Checks parameter invalidity
    function testInvalidParameters() public {
        uint256 revTicketPrice = 0;
        uint256 revMaxTicketCount = 0;

        vm.expectRevert("Lottery: invalid ticket price");

        new Lottery(revTicketPrice, _maxTicketCount);

        vm.expectRevert("Lottery: invalid ticket count");

        new Lottery(_ticketPrice, revMaxTicketCount);
    }
}
