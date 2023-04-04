// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/StdJson.sol";
import {ENSExpirationManager} from "@src/ENSExpirationManager.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ENSExpirationManagerNetworkForkTest is Test {
    using stdJson for string;

    ENSExpirationManager ensExpirationManager;
    address admin;
    address whale;
    address keeperAddress;
    uint256 network;
    bytes performData;
    string domainName1;
    string domainName2;
    string domainName3;
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
        uint256 duration;
        uint256 gracePeriod;
        domainName1 = "vitalik";
        domainName2 = "lnbox";
        duration = 4838400;
        gracePeriod = 241920;

        ensExpirationManager.addSubscription{value: 2 ether}(
            domainName1,
            duration,
            gracePeriod
        );
    }

    function testFork_AddSubscription() public {
        forkSubscriptionFixture();
    }

    function testFork_CancelSubscriptions() public {
        forkSubscriptionFixture();
        vm.prank(whale);
        uint256 tokenId = uint256(keccak256(bytes(domainName1)));
        uint256 subscriptionId = uint256(
            keccak256(abi.encodePacked(tokenId, whale))
        );
        ensExpirationManager.cancelSubscription(subscriptionId);
    }

    function testFork_PerformUpkeepRenewSingleDomain() public {
        forkSubscriptionFixture();
        keeperAddress = address(config.keeperAddress);
        vm.prank(keeperAddress);
        uint256 tokenId = uint256(keccak256(bytes(domainName1)));
        uint256 subscriptionId = uint256(
            keccak256(abi.encodePacked(tokenId, whale))
        );
        uint256[] memory expiredToBeRenewedIds = new uint256[](1);
        expiredToBeRenewedIds[0] = subscriptionId;
        performData = abi.encode(expiredToBeRenewedIds);
        ensExpirationManager.performUpkeep(performData);
    }

    function testFork_WithdrawProtocolFees() public {
        testFork_PerformUpkeepRenewSingleDomain();
        assertEq(
            ensExpirationManager.getWithdrawableProtocolFeePoolBalance(),
            100000000000000000
        );
        vm.prank(admin);
        ensExpirationManager.withdrawProtocolFees();
        assertEq(
            ensExpirationManager.getWithdrawableProtocolFeePoolBalance(),
            0
        );
    }
}
