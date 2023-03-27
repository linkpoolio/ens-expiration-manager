// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "forge-std/StdJson.sol";
// import {ENSExpirationManager} from "@src/ENSExpirationManager.sol";
// import {AutomationMock} from "@src/mock/AutomationMock.sol";

// contract ENSExpirationManagerTest is Test {
//     address _priceOracle;
//     address _keeperAddress;
//     address _baseRegistrar;
//     address _registrarController;
//     uint256 _protocolFee;
//     address admin;
//     address whale;

//     function setUp() public {
//         admin = makeAddr("admin");
//         whale = address(config.whale);
//         _priceOracle = address(0x000);
//         _keeperAddress = new AutomationMock();
//         _baseRegistrar = address(0x000);
//         _registrarController = address(0x000);
//         _protocolFee = 0;

//         vm.startPrank(admin);
//         ensExpirationManager = new ENSExpirationManager(
//             _priceOracle,
//             _keeperAddress,
//             _baseRegistrar,
//             _registrarController,
//             _protocolFee
//         );
//         vm.stopPrank();
//     }
// }
