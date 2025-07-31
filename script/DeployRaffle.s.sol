// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        AddConsumer addConsumer = new AddConsumer();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            // Fixed: Use correct field name and remove non-existent account parameter
            (config.subscriptionId, config.vrfCoordinator) =
                createSubscription.createSubscription(config.vrfCoordinator);

            FundSubscription fundSubscription = new FundSubscription();
            // Fixed: Use correct field names and remove account parameter
            fundSubscription.fundSubscription(
                config.vrfCoordinator, 
                config.subscriptionId, 
                config.link
            );

            helperConfig.setConfig(block.chainid, config);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.subscriptionId,     // Already uint64
            config.gasLane,
            config.interval,           // Fixed: Use correct field name
            config.entranceFee,        // Fixed: Use correct field name
            config.callbackGasLimit,
            config.vrfCoordinator      // Fixed: Use correct field name
        );
        vm.stopBroadcast();

        // We already have a broadcast in here
        // Fixed: Use correct field names and remove account parameter
        addConsumer.addConsumer(
            address(raffle), 
            config.vrfCoordinator, 
            config.subscriptionId
        );
        
        return (raffle, helperConfig);
    }
}
