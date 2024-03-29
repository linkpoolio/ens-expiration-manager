// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import {ENSExpirationManager} from "@src/ENSExpirationManager.sol";

contract ENSExpirationManagerScript is Script {
    using stdJson for string;

    ENSExpirationManager ensExpirationManager;
    uint256 deployerPrivateKey;
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

    function run() public {
        config = configureNetwork("config");
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);

        ensExpirationManager = new ENSExpirationManager(
            config.priceOracle,
            config.keeperAddress,
            config.baseRegistrarAddress,
            config.registrarControllerAddress,
            config.protocolFee
        );

        vm.stopBroadcast();
    }
}
