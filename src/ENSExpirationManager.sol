// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IENSExpirationManager} from "./interfaces/IENSExpirationManager.sol";

import {ETHRegistrarController} from "@ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";
import {BaseRegistrarImplementation} from "@ens-contracts/contracts/ethregistrar/BaseRegistrarImplementation.sol";

contract ENSExpirationManager is
    IENSExpirationManager,
    AutomationCompatibleInterface,
    Pausable
{
    /// @dev The BaseRegistrarImplementation contract
    BaseRegistrarImplementation baseRegistrar;
    /// @dev The ETHRegistrarController contract
    ETHRegistrarController registrarController;
    address public owner;
    address public keeperRegistryAddress;
    uint256 public protocolFee;
    uint256[] private subscriptionIds;
    /// @dev Mapping of tokenIds to the subscription
    mapping(uint256 => Subscription) public subscriptions;
    /// @dev Mapping of owner address to the amount of deposit
    mapping(address => uint256) public deposits;

    struct Subscription {
        address owner;
        string domainName;
        uint256 renewalDuration;
        uint256 gracePeriod;
    }

    /**
     * Modifiers ***********************************************
     */

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyKeeperRegistry() {
        if (msg.sender != keeperRegistryAddress) {
            revert OnlyKeeperRegistry();
        }
        _;
    }

    /**
     * @notice Initialize a ENSExpirationManager contract
     * @param _keeperAddress The address of the KeeperRegistry contract
     * @param _protocolFee The protocol fee
     * @param _registrarController The address of the ETHRegistrarController contract
     * @param _baseRegistrar The address of the BaseRegistrarImplementation contract
     */
    constructor(
        address _keeperAddress,
        address _baseRegistrar,
        address _registrarController,
        uint256 _protocolFee
    ) {
        require(
            _keeperAddress != address(0),
            "Keeper Registry address cannot be 0x0"
        );
        require(
            _baseRegistrar != address(0),
            "Base Registrar address cannot be 0x0"
        );
        require(
            _registrarController != address(0),
            "Registrar Controller address cannot be 0x0"
        );
        owner = msg.sender;
        setKeeperRegistryAddress(_keeperAddress);
        setProtocolFee(_protocolFee);
        setRegistrarController(_registrarController);
        setBaseRegistrar(_baseRegistrar);
    }

    /**
     * Admin ***************************************************
     */

    /**
     * @notice This method is called to top up the deposit
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    /**
     * @notice This method is called to set the Keeper Registry Address
     */
    function setKeeperRegistryAddress(address _keeperAddress) public onlyOwner {
        if (_keeperAddress == address(0)) {
            revert ZeroAddress();
        }
        keeperRegistryAddress = _keeperAddress;
    }

    /**
     * @notice This method is called to set the ENS Registrar Controller
     */
    function setRegistrarController(
        address _registrarController
    ) public onlyOwner {
        if (_registrarController == address(0)) {
            revert ZeroAddress();
        }
        registrarController = ETHRegistrarController(_registrarController);
    }

    /**
     * @notice This method is called to set the base registrar
     */
    function setBaseRegistrar(address _baseRegistrar) public onlyOwner {
        if (_baseRegistrar == address(0)) {
            revert ZeroAddress();
        }
        baseRegistrar = BaseRegistrarImplementation(_baseRegistrar);
    }

    /**
     * @notice This method is called to set the protocol fee
     */
    function setProtocolFee(uint256 _protocolFee) public onlyOwner {
        protocolFee = _protocolFee;
    }

    /**
     * @notice Pause to prevent executing performUpkeep.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * Internal ***********************************************
     */

    /**
     * @notice This method is called to get the owner of the ENS Domain
     */
    function stringToTokenId(
        string memory _name
    ) public pure returns (uint256) {
        bytes32 labelHash = keccak256(bytes(_name));
        return uint256(labelHash);
    }

    /**
     * @notice This method is called internally to add a domain subscription
     */
    function _addDomainSubscription(
        string memory _domainName,
        uint256 _renewalDuration,
        uint256 _gracePeriod
    ) internal {
        uint256 _tokenId = stringToTokenId(_domainName);
        uint256 currentExpiration = baseRegistrar.nameExpires(_tokenId);
        if (_getTokenOwner(_tokenId) != msg.sender) {
            revert InvalidOwner();
        }
        if (currentExpiration < block.timestamp) {
            revert DomainAlreadyExpired();
        }
        if (
            currentExpiration - _gracePeriod <= block.timestamp ||
            _gracePeriod == 0
        ) {
            revert InvalidGracePeriod();
        }
        if (_renewalDuration < 28 * 24 * 60 * 60) {
            revert InvalidRenewalDuration();
        }
        Subscription memory newSubscription = Subscription(
            msg.sender,
            _domainName,
            _renewalDuration,
            _gracePeriod
        );
        subscriptions[_tokenId] = newSubscription;
        subscriptionIds.push(_tokenId);
        emit DomainSubscriptionAdded(
            msg.sender,
            _domainName,
            _renewalDuration,
            _gracePeriod
        );
    }

    /**
     * @notice This method is called to remove a subscription
     */
    function _deleteSubscription(uint256 _tokenId) internal {
        for (uint256 i = 0; i < subscriptionIds.length; i++) {
            if (subscriptionIds[i] == _tokenId) {
                subscriptionIds[i] = subscriptionIds[
                    subscriptionIds.length - 1
                ];
                subscriptionIds.pop();
                delete subscriptions[_tokenId];
                emit DomainSubscriptionRemoved(_tokenId);
            }
        }
    }

    /**
     * @notice This method gets the current owner of the ENS Domain
     */
    function _getTokenOwner(uint256 _tokenId) internal view returns (address) {
        return baseRegistrar.ownerOf(_tokenId);
    }

    /**
     * @notice This method is called by the Keeper to check if the domain is expiring
     */
    function _isExpiring(uint256 _tokenId) internal view returns (bool) {
        return
            baseRegistrar.nameExpires(_tokenId) -
                subscriptions[_tokenId].gracePeriod <=
            block.timestamp;
    }

    /**
     * @notice This method is called by the Keeper to renew the domain. If the subscription owner does not have enough funds, the subscription is removed.
     * @dev This method is called by the KeeperRegistry contract
     * @param _tokenId The token ID of the ENS Domain
     */
    function _renewDomain(uint256 _tokenId) internal {
        address owner = subscriptions[_tokenId].owner;
        uint256 renewalPrice = registrarController
            .rentPrice(
                subscriptions[_tokenId].domainName,
                subscriptions[_tokenId].renewalDuration
            )
            .base;
        deposits[owner] -= (protocolFee + renewalPrice);
        baseRegistrar.renew(_tokenId, subscriptions[_tokenId].renewalDuration);
        emit DomainSubscriptionRenewed(_tokenId);
    }

    /**
     * External ***********************************************
     */

    /**
     * @notice This method is called to top up the deposit amount
     */
    function topUpDeposit() external payable {
        if (msg.value == 0) {
            revert InvalidTopUpAmount();
        }
        deposits[msg.sender] += msg.value;
        emit DepositToppedUp(msg.sender, msg.value);
    }

    /**
     * @notice This method is called to withdraw the deposited funds
     */
    function withdrawDeposit(uint256 _amount) external {
        if (_amount == 0 || _amount > deposits[msg.sender]) {
            revert InvalidWithdrawAmount();
        }
        payable(msg.sender).transfer(_amount);
        deposits[msg.sender] -= _amount;
        emit DepositWithdrawn(msg.sender, _amount);
    }

    /**
     * @notice This method is called to add subscriptions
     */
    function addSubscriptions(
        string[] memory _domainNames,
        uint256[] memory _renewalDurations,
        uint256[] memory _gracePeriods
    ) external {
        if (
            _renewalDurations.length != _gracePeriods.length ||
            _gracePeriods.length != _domainNames.length
        ) {
            revert InvalidSubscriptionsLength();
        }
        for (uint256 i = 0; i < _domainNames.length; i++) {
            _addDomainSubscription(
                _domainNames[i],
                _renewalDurations[i],
                _gracePeriods[i]
            );
        }
    }

    /**
     * @notice This method is called to remove subscriptions
     */
    function removeSubscriptions(uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (
                subscriptions[_tokenIds[i]].owner != msg.sender &&
                _getTokenOwner(_tokenIds[i]) != msg.sender
            ) {
                revert NotOwnerOfSubscription();
            }

            _deleteSubscription(_tokenIds[i]);
        }
    }

    /**
     * @notice This method is called to get the subscription details
     */
    function getSubscription(
        uint256 _tokenId
    ) external view returns (Subscription memory) {
        return subscriptions[_tokenId];
    }

    /**
     * Automation ***********************************************
     */

    /**
     * @notice Check if upkeep is needed. This method is called by the Keeper.
     * @return upkeepNeeded True if upkeep is needed, False otherwise
     * @return performData ABI-encoded data to pass to the performUpkeep
     */
    function checkUpkeep(
        bytes calldata /* checkData */
    ) external override returns (bool upkeepNeeded, bytes memory performData) {
        uint256[] memory expiredDomainSubscriptionIds = new uint256[](0);
        uint256 expiredDomainSubscriptionIdsCount = 0;
        uint256[] memory invalidSubscriptionsIds = new uint256[](0);
        uint256 invalidSubscriptionsIdsCount = 0;

        for (uint256 i = 0; i < subscriptionIds.length; i++) {
            uint256 tokenId = subscriptionIds[i];
            // If the owner of the subscription is not the owner of the ENS Domain, delete the subscription
            if (subscriptions[tokenId].owner != _getTokenOwner(tokenId)) {
                invalidSubscriptionsIds[invalidSubscriptionsIdsCount] = tokenId;
                invalidSubscriptionsIdsCount++;
                emit DomainSubscriptionRemoved(tokenId);
                continue;
            }
            if (
                _isExpiring(tokenId) &&
                deposits[subscriptions[tokenId].owner] <
                protocolFee +
                    registrarController
                        .rentPrice(
                            subscriptions[tokenId].domainName,
                            subscriptions[tokenId].renewalDuration
                        )
                        .base
            ) {
                expiredDomainSubscriptionIds[
                    expiredDomainSubscriptionIdsCount
                ] = tokenId;
                expiredDomainSubscriptionIdsCount++;
                emit DomainSubscriptionExpired(tokenId);
            }
        }
        if (expiredDomainSubscriptionIds.length > 0) {
            upkeepNeeded = true;
            performData = abi.encode(
                expiredDomainSubscriptionIds,
                invalidSubscriptionsIds
            );
        }
        return (upkeepNeeded, performData);
    }

    /**
     * @notice Perform the upkeep. This method is called by the Keeper.
     * @param performData ABI-encoded data to pass to the performUpkeep
     */
    function performUpkeep(
        bytes calldata performData
    ) external override onlyKeeperRegistry whenNotPaused {
        uint256[] memory expiredDomainSubscriptionIds;
        uint256[] memory invalidSubscriptionsIds;
        (expiredDomainSubscriptionIds, invalidSubscriptionsIds) = abi.decode(
            performData,
            (uint256[], uint256[])
        );
        if (invalidSubscriptionsIds.length > 0) {
            for (uint256 i = 0; i < invalidSubscriptionsIds.length; i++) {
                _deleteSubscription(invalidSubscriptionsIds[i]);
            }
        }
        for (uint256 i = 0; i < expiredDomainSubscriptionIds.length; i++) {
            _renewDomain(expiredDomainSubscriptionIds[i]);
        }
    }
}
