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
        uint256 renewalCount;
        domainName1 = "vitalik";
        domainName2 = "lnbox";
        duration = 4838400;
        gracePeriod = 241920;
        renewalCount = 3;

        ensExpirationManager.addSubscription{value: 2 ether}(
            domainName1,
            duration,
            renewalCount,
            gracePeriod
        );
    }

    function testFork_AddSubscription() public {
        forkSubscriptionFixture();
    }

    function testFork_CancelSubscriptions() public {
        forkSubscriptionFixture();
        vm.prank(whale);
        uint256 tokenId1 = uint256(keccak256(bytes(domainName1)));
        ensExpirationManager.cancelSubscription(tokenId1);
    }

    function testFork_PerformUpkeepRenewSingleDomain() public {
        forkSubscriptionFixture();
        keeperAddress = address(config.keeperAddress);
        vm.prank(keeperAddress);
        uint256 tokenId1 = uint256(keccak256(bytes(domainName1)));
        uint256[] memory expiredToBeRenewedIds = new uint256[](1);
        expiredToBeRenewedIds[0] = tokenId1;
        uint256[] memory invalidSubscriptionsIds = new uint256[](0);
        performData = abi.encode(
            expiredToBeRenewedIds,
            invalidSubscriptionsIds
        );
        ensExpirationManager.performUpkeep(performData);
    }

    function testFork_WithdrawProtocolFees() public {
        testFork_PerformUpkeepRenewSingleDomain();
        vm.prank(admin);
        ensExpirationManager.withdrawProtocolFees();
        uint256 withdrawableProtocolFeePool = ensExpirationManager
            .getWithdrawableProtocolFeePoolBalance();
        assertEq(withdrawableProtocolFeePool, 0);
    }
}
