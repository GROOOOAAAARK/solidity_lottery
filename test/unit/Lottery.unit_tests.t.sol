// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Lottery } from "@contracts/Lottery.sol";
import { LotteryDeployLocal } from "@tests/unit/Lottery.deploy_tests.t.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryUnitTestsLocal is Script {
    Lottery lotteryContract;
    address _user;
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

        uint256 userPvK = vm.deriveKey(mnemonic, 1);
        _user = vm.addr(userPvK);

        console.log("Owner: %s (default active user) --- User: %s\n\n", _owner, _user);
    }

    // @dev Start Lottery conditions
    function testStartLottery() public {
        // Test nobody can start the lottery except the owner
        vm.prank(_user);
        vm.expectRevert("Ownable: caller is not the owner"); //"OwnableUnauthorizedAccount(%s)", _user
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

        // Invalid user permissions
        vm.prank(_user);
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

}