// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/StdJson.sol";
import {ENSExpirationManager} from "@src/ENSExpirationManager.sol";

contract ENSExpirationManagerNetworkForkTest is Test {
    using stdJson for string;

    ENSExpirationManager ensExpirationManager;
    address admin;
    address whale;
    uint256 network;
    Config config;

    struct Config {
        address baseRegistrarAddress;
        address keeperAddress;
        string name;
        address priceOracle;
        uint256 protocolFee;
        address registrarControllerAddress;
        address whale;
    }

    function configureNetwork(
        string memory input
    ) internal view returns (Config memory) {
        string memory inputDir = string.concat(
            vm.projectRoot(),
            "/script/input/"
        );
        string memory chainDir = string.concat(vm.toString(block.chainid), "/");
        string memory file = string.concat(input, ".json");
        string memory data = vm.readFile(
            string.concat(inputDir, chainDir, file)
        );
        bytes memory rawConfig = data.parseRaw("");
        return abi.decode(rawConfig, (Config));
    }

    function setUp() public {
        network = vm.createSelectFork(vm.rpcUrl("mainnet"));
        config = configureNetwork("config");
        admin = makeAddr("admin");
        whale = address(config.whale);

        vm.startPrank(admin);
        ensExpirationManager = new ENSExpirationManager(
            config.priceOracle,
            config.keeperAddress,
            config.baseRegistrarAddress,
            config.registrarControllerAddress,
            config.protocolFee
        );
        vm.stopPrank();
    }

    function forkSubscriptionFixture() public {
        vm.selectFork(network);
        vm.prank(whale);
        string memory domainName;
        uint256 duration;
        uint256 gracePeriod;
        domainName = "vitalik";
        duration = 4838400;
        gracePeriod = 241920;

        ensExpirationManager.addSubscription{value: 1 ether}(
            domainName,
            duration,
            gracePeriod
        );
        uint256 protocolFeePool = ensExpirationManager
            .getProtocolFeePoolBalance();
        assertEq(protocolFeePool, 100000000000000000);
    }

    function testFork_AddSubscriptions() public {
        forkSubscriptionFixture();
    }

    function testFork_CancelSubscriptions() public {
        forkSubscriptionFixture();
        vm.prank(whale);
        uint256 tokenId = 79233663829379634837589865448569342784712482819484549289560981379859480642508;
        ensExpirationManager.cancelSubscription(tokenId);
    }

    function testFork_WithdrawProtocolFees() public {
        forkSubscriptionFixture();
        vm.prank(admin);
        ensExpirationManager.withdrawProtocolFees();
        uint256 protocolFeePool = ensExpirationManager
            .getProtocolFeePoolBalance();
        assertEq(protocolFeePool, 0);
    }

    // function testFork_PerformUpkeep() public {}
}
