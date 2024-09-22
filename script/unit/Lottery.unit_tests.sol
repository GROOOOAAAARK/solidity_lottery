// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Lottery } from "@contracts/Lottery.sol";
import { LotteryDeployLocal } from "./Lottery.deploy_tests.sol";

contract LotteryUnitTestsLocal is Script {
    Lottery lotteryContract;
    address _user;
    address _owner;

    function setUp() public {
        vm.startBroadcast();

        string memory mnemonic = vm.envString("MNEMONIC");
        console.log("Mnemonic: %s", mnemonic);
        uint256 ownerPvK = vm.deriveKey(mnemonic, 0);
        user = vm.addr(pvK);
        vm.prank(user);

        LotteryDeployLocal deployer = new LotteryDeployLocal();
        address payable lotteryAddress = deployer._deploy(10, 5);
        lotteryContract = Lottery(lotteryAddress);
    }

}