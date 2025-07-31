// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {CodeConstants} from "./HelperConfig.s.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64, address) {
        HelperConfig helperConfig = new HelperConfig();
        // Fixed: Use 'vrfCoordinator' instead of 'vrfCoordinatorV2_5'
        address vrfCoordinator = helperConfig.getConfigByChainId(block.chainid).vrfCoordinator;
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint64, address) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return (subId, vrfCoordinator);
    }

    function run() external returns (uint64, address) {
        return createSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(address contractToAddToVrf, address vrfCoordinator, uint64 subId) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, contractToAddToVrf);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        uint64 subId = helperConfig.getConfig().subscriptionId;
        // Fixed: Use 'vrfCoordinator' instead of 'vrfCoordinatorV2_5'
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}

contract FundSubscription is CodeConstants, Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        uint64 subId = helperConfig.getConfig().subscriptionId;
        // Fixed: Use 'vrfCoordinator' instead of 'vrfCoordinatorV2_5'
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address link = helperConfig.getConfig().link;

        if (subId == 0) {
            CreateSubscription createSub = new CreateSubscription();
            (uint64 updatedSubId, address updatedVRF) = createSub.run();
            subId = updatedSubId;
            vrfCoordinator = updatedVRF;
            console.log("New SubId Created! ", subId, "VRF Address: ", vrfCoordinator);
        }

        fundSubscription(vrfCoordinator, subId, link);
    }

    function fundSubscription(address vrfCoordinator, uint64 subId, address link) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast();
            LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
