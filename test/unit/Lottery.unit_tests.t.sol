// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Lottery } from "@contracts/Lottery.sol";
import { LotteryDeployLocal } from "@tests/unit/Lottery.deploy_tests.t.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryUnitTestsLocal is Script {
    Lottery lotteryContract;
    address _user1;
    address _user2;
    address _owner;

    function setUp() public {
        string memory mnemonic = vm.envString("MNEMONIC");
        console.log("Mnemonic: %s", mnemonic);
        uint256 ownerPvK = vm.deriveKey(mnemonic, 0);
        _owner = vm.addr(ownerPvK);
        vm.prank(_owner);

        LotteryDeployLocal deployer = new LotteryDeployLocal();
        address payable lotteryAddress = deployer._deploy(10, 3, _owner);
        lotteryContract = Lottery(lotteryAddress);

        uint256 user1PvK = vm.deriveKey(mnemonic, 1);
        _user1 = vm.addr(user1PvK);

        uint256 user2PvK = vm.deriveKey(mnemonic, 2);
        _user2 = vm.addr(user2PvK);

        vm.deal(_owner, 1000);
        vm.deal(_user1, 1000);
        vm.deal(_user2, 1000);

        console.log("Owner: %s (default active user1) --- User: %s\n\n", _owner, _user1);
    }

    // @dev Start Lottery conditions
    function testStartLottery() public {
        // Test nobody can start the lottery except the owner
        vm.prank(_user1);
        vm.expectRevert("Ownable: caller is not the owner"); //"OwnableUnauthorizedAccount(%s)", _user1
        lotteryContract.startLottery();
        vm.stopPrank();

        // Test the owner can start the lottery
        vm.expectEmit(true, true, true, true);
        emit Lottery.LotteryStarted(lotteryContract.ticketPrice(), lotteryContract.maxTicketCount());
        vm.prank(_owner);
        lotteryContract.startLottery();

        // Test the owner cannot start the lottery if already started
        vm.expectRevert(); //"Lottery: already started or ended"
        lotteryContract.startLottery();
        vm.stopPrank();
    }

    // @dev Reset Lottery conditions
    function testReset() public {
        uint256 newTicketPrice = 10;
        uint256 newMaxTicketCount = 10;

        // Invalid user1 permissions
        vm.prank(_user1);
        vm.expectRevert("Ownable: caller is not the owner");
        lotteryContract.resetLottery(newTicketPrice, newMaxTicketCount);
        vm.stopPrank();

        // Invalid lottery state
        vm.prank(_owner);
        vm.expectRevert("Lottery: not ended");
        lotteryContract.resetLottery(newTicketPrice, newMaxTicketCount);

        // // Valid state and permissions: check state, new price and ticket count
        // vm.setArbitraryStorage(payable(address(lotteryContract)));
        // lotteryContract._lotteryState = lotteryContract.State.Ended;
        // lotteryContract.resetLottery(newTicketPrice, newMaxTicketCount);
        // assert(lotteryContract._ticketPrice == newTicketPrice);
        // assert(lotteryContract._maxTicketCount == newMaxTicketCount);
        vm.stopPrank();
    }

    /* @dev buyTicket
        - [ ] Test ok
        - [ ] Test not enought msg value
        - [ ] Test for endLottery and get random winner
        // - [ ] Te
    */
    function testBuyTicket() public {

        vm.prank(_owner);
        lotteryContract.startLottery();
        vm.stopPrank();

        // Test buy function OK
        vm.startPrank(_user1);
        lotteryContract.buyTicket{value: lotteryContract.ticketPrice()}();
        assert(lotteryContract.ticketsSold() == 1);
        assert(lotteryContract.ticketsLeft() == lotteryContract.maxTicketCount() - 1);
        assert(address(lotteryContract).balance == lotteryContract.ticketPrice() * 1);

        // Test buy wrong value too low
        uint256 badValueLow = lotteryContract.ticketPrice() - 1;
        vm.expectRevert("Lottery: invalid ticket price");
        lotteryContract.buyTicket{value: badValueLow}();

        // Test buy wrong value too high
        uint256 badValueHigh = lotteryContract.ticketPrice() + 1;
        vm.expectRevert("Lottery: invalid ticket price");
        lotteryContract.buyTicket{value: badValueHigh}();

        vm.stopPrank();

        vm.prank(_user2);
        lotteryContract.buyTicket{value: lotteryContract.ticketPrice()}();
        assert(lotteryContract.ticketsSold() == 2);
        assert(lotteryContract.ticketsLeft() == lotteryContract.maxTicketCount() - 2);
        assert(address(lotteryContract).balance == lotteryContract.ticketPrice() * 2);

        vm.stopPrank();

        vm.prank(_owner);
        lotteryContract.buyTicket{value: lotteryContract.ticketPrice()}();
        assert(lotteryContract.ticketsSold() == 3);
        assert(lotteryContract.ticketsLeft() == lotteryContract.maxTicketCount() - 3);
        assert(lotteryContract.state() == Lottery.State.Ended);
    }
}