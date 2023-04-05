// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IENSExpirationManager} from "./interfaces/IENSExpirationManager.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeMath} from "../lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import {Address} from "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
import {ETHRegistrarController} from "@ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";
import {BaseRegistrarImplementation} from "@ens-contracts/contracts/ethregistrar/BaseRegistrarImplementation.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

contract ENSExpirationManager is
    IENSExpirationManager,
    AutomationCompatibleInterface,
    Pausable,
    ReentrancyGuard
{
    using SafeMath for uint256;
    using Address for address;
    /// @dev The BaseRegistrarImplementation contract
    BaseRegistrarImplementation baseRegistrar;
    /// @dev The ETHRegistrarController contract
    ETHRegistrarController registrarController;
    IPriceOracle priceOracle;
    address public owner;
    address public keeperRegistryAddress;
    uint256 public protocolFee;
    uint256 public withdrawableProtocolFeePool;
    uint256[] private subscriptionIds;
    /// @dev Mapping of subscriptionIds to the subscription
    mapping(uint256 => Subscription) public subscriptions;
    /// @dev Mapping of subscriptionIds to the bool value
    mapping(uint256 => bool) public subscriptionIdExists;

    enum SubscriptionState {
        CANCELLED,
        ACTIVE
    }

    struct Subscription {
        address owner;
        string domainName;
        uint256 renewalDuration;
        uint256 gracePeriod;
        uint256 deposit;
        SubscriptionState state;
    }

    /**
     * Modifiers ***********************************************
     */

    /**
     * @notice Modifier to check if the caller is the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice Modifier to check if the caller is the keeper registry
     */
    modifier onlyKeeperRegistry() {
        if (msg.sender != keeperRegistryAddress) {
            revert OnlyKeeperRegistry();
        }
        _;
    }

    /**
     * Constructor *********************************************
     */

    /**
     * @notice Initialize a ENSExpirationManager contract
     * @param _priceOracle The address of the PriceOracle contract
     * @param _keeperAddress The address of the KeeperRegistry contract
     * @param _protocolFee The protocol fee
     * @param _registrarController The address of the ETHRegistrarController contract
     * @param _baseRegistrar The address of the BaseRegistrarImplementation contract
     */
    constructor(
        address _priceOracle,
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
        setPriceOracle(_priceOracle);
        setKeeperRegistryAddress(_keeperAddress);
        setProtocolFee(_protocolFee);
        setRegistrarController(_registrarController);
        setBaseRegistrar(_baseRegistrar);
    }

    /**
     * Admin ***************************************************
     */

    /**
     * @notice This method is called to withdraw the protocol fees
     */
    function withdrawProtocolFees() external onlyOwner {
        require(
            withdrawableProtocolFeePool > 0,
            "No fees available for withdrawal"
        );
        uint256 amount = withdrawableProtocolFeePool;
        withdrawableProtocolFeePool = 0;
        Address.sendValue(payable(msg.sender), amount);
        emit ProtocolFeesWithdrawn(msg.sender, amount);
    }

    /**
     * @notice This method is called to top up the deposit
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    /**
     * @notice This method is called to set the price oracle
     */
    function setPriceOracle(address _priceOracle) public onlyOwner {
        if (_priceOracle == address(0)) {
            revert ZeroAddress();
        }
        priceOracle = IPriceOracle(_priceOracle);
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
            baseRegistrar.nameExpires(_tokenId).sub(
                subscriptions[_tokenId].gracePeriod
            ) <= block.timestamp;
    }

    /**
     * External ***********************************************
     */

    /**
     * @notice This method is called to return all the subscription instances
     */
    function getAllSubscriptions()
        external
        view
        returns (Subscription[] memory)
    {
        Subscription[] memory _subscriptions = new Subscription[](
            subscriptionIds.length
        );
        for (uint256 i = 0; i < subscriptionIds.length; i++) {
            _subscriptions[i] = subscriptions[subscriptionIds[i]];
        }
        return _subscriptions;
    }

    /**
     * @notice This method is called to get the balance of the withdrawable protocol fee pool
     */
    function getWithdrawableProtocolFeePoolBalance()
        external
        view
        returns (uint256)
    {
        return withdrawableProtocolFeePool;
    }

    /**
     * @notice Add a subscription for a domain
     * @param _domainName The domain name to be subscribed
     * @param _renewalDuration The duration for each renewal in seconds
     * @param _gracePeriod The grace period in seconds before the domain expires for when the subscription will be renewed
     * @dev This function is non-reentrant to prevent potential reentrancy attacks
     */
    function addSubscription(
        string memory _domainName,
        uint256 _renewalDuration,
        uint256 _gracePeriod
    ) external payable nonReentrant {
        uint256 _tokenId = uint256(keccak256(bytes(_domainName)));
        uint256 _currentExpiration = baseRegistrar.nameExpires(_tokenId);
        uint256 subscriptionId = uint256(
            keccak256(abi.encodePacked(_tokenId, msg.sender))
        );
        // Check if the subscription exists and is cancelled before adding a new one
        require(
            subscriptions[subscriptionId].state == SubscriptionState.CANCELLED,
            "SubscriptionExists"
        );
        require(_getTokenOwner(_tokenId) == msg.sender, "InvalidOwner");
        require(
            _currentExpiration.sub(_gracePeriod) > block.timestamp ||
                _gracePeriod != 0,
            "InvalidGracePeriod"
        );
        require(
            _renewalDuration >= 28 * 24 * 60 * 60,
            "InvalidRenewalDuration"
        );
        Subscription memory newSubscription = Subscription(
            msg.sender,
            _domainName,
            _renewalDuration,
            _gracePeriod,
            msg.value,
            SubscriptionState.ACTIVE
        );
        if (subscriptionIdExists[subscriptionId] == false) {
            subscriptionIdExists[subscriptionId] = true;
            subscriptionIds.push(subscriptionId);
            subscriptions[subscriptionId] = newSubscription;
            emit DomainSubscriptionAdded(subscriptionId);
        } else {
            // If the subscription exists, update the subscription
            subscriptions[subscriptionId] = newSubscription;
            emit DomainSubscriptionUpdated(subscriptionId);
        }
    }

    /**
     * @notice Top up an existing domain subscription
     * @param _subscriptionId The subscription ID representing the domain subscription to be topped up
     * @dev This function is non-reentrant to prevent potential reentrancy attacks
     */
    function topUpSubscription(
        uint256 _subscriptionId
    ) external payable nonReentrant {
        Subscription storage subscription = subscriptions[_subscriptionId];
        if (subscription.owner != msg.sender) {
            revert("InvalidOwner");
        }
        if (subscription.state == SubscriptionState.CANCELLED) {
            revert("SubscriptionCancelled");
        }
        subscription.deposit = subscription.deposit.add(msg.value);
        emit DomainSubscriptionTopUp(_subscriptionId, msg.value);
    }

    /**
     * @notice Cancel an existing domain subscription
     * @param _subscriptionId The subscription ID representing the domain subscription to be cancelled
     * @dev This function is non-reentrant to prevent potential reentrancy attacks
     */
    function cancelSubscription(uint256 _subscriptionId) external nonReentrant {
        Subscription storage subscription = subscriptions[_subscriptionId];
        if (subscription.owner != msg.sender) {
            revert("InvalidOwner");
        }
        if (subscription.state == SubscriptionState.CANCELLED) {
            revert("SubscriptionCancelled");
        }
        Address.sendValue(payable(msg.sender), subscription.deposit);
        subscription.deposit = 0;
        subscription.state = SubscriptionState.CANCELLED;
        emit DomainSubscriptionCancelled(_subscriptionId);
    }

    /**
     * @notice This method is called to get the subscription details
     */
    function getSubscription(
        uint256 _subscriptionId
    ) external view returns (Subscription memory) {
        return subscriptions[_subscriptionId];
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
        uint256[] memory expiredDomainSubscriptionIds = new uint256[](
            subscriptionIds.length
        );
        uint256 expiredDomainSubscriptionIdsCount = 0;
        for (uint256 i = 0; i < subscriptionIds.length; i++) {
            uint256 _subscriptionId = subscriptionIds[i];
            Subscription storage subscription = subscriptions[_subscriptionId];
            uint256 tokenId = uint256(
                keccak256(bytes(subscription.domainName))
            );
            // Skip if the subscription is cancelled or the owner is not the current owner of the domain
            if (
                subscription.state == SubscriptionState.CANCELLED ||
                subscription.owner != _getTokenOwner(tokenId)
            ) {
                continue;
            }
            uint256 currentExpiration = baseRegistrar.nameExpires(tokenId);
            uint256 price = priceOracle.price(
                subscriptions[tokenId].domainName,
                currentExpiration,
                subscriptions[tokenId].renewalDuration
            );
            uint256 rentPrice = registrarController
                .rentPrice(
                    subscriptions[tokenId].domainName,
                    subscriptions[tokenId].renewalDuration
                )
                .base;
            uint256 renewalPrice = price.add(protocolFee).add(rentPrice);
            if (
                _isExpiring(tokenId) &&
                subscriptions[tokenId].deposit >= renewalPrice
            ) {
                expiredDomainSubscriptionIds[
                    expiredDomainSubscriptionIdsCount++
                ] = tokenId;
            }
        }
        // Adjust array sizes to match the actual number of elements
        uint256[] memory adjustedExpiredDomainSubscriptionIds = new uint256[](
            expiredDomainSubscriptionIdsCount
        );
        for (uint256 i = 0; i < expiredDomainSubscriptionIdsCount; i++) {
            adjustedExpiredDomainSubscriptionIds[
                i
            ] = expiredDomainSubscriptionIds[i];
        }
        if (expiredDomainSubscriptionIdsCount > 0) {
            upkeepNeeded = true;
            performData = abi.encode(adjustedExpiredDomainSubscriptionIds);
            emit DomainSubscriptionsCheckCompleted(
                adjustedExpiredDomainSubscriptionIds
            );
        }
        return (upkeepNeeded, performData);
    }

    /**
     * @notice Perform the upkeep. This method is called by the Keeper.
     * @param performData ABI-encoded data to pass to the performUpkeep
     * @dev This function is non-reentrant to prevent potential reentrancy attacks
     * @dev The performData is decoded to get the expiredDomainSubscriptionIds
     * @dev The expiredDomainSubscriptionIds are processed to renew the domains
     * @dev The invalidSubscriptionsIds are processed to refund the deposits
     */
    function performUpkeep(
        bytes calldata performData
    ) external override onlyKeeperRegistry whenNotPaused nonReentrant {
        uint256[] memory expiredDomainSubscriptionIds = abi.decode(
            performData,
            (uint256[])
        );
        // Process renewals for expired domain subscriptions
        for (uint256 i = 0; i < expiredDomainSubscriptionIds.length; i++) {
            uint256 subscriptionId = expiredDomainSubscriptionIds[i];
            Subscription storage subscription = subscriptions[subscriptionId];
            uint256 tokenId = uint256(
                keccak256(bytes(subscription.domainName))
            );
            uint256 currentExpiration = baseRegistrar.nameExpires(tokenId);
            uint256 renewalPrice = priceOracle.price(
                subscription.domainName,
                currentExpiration,
                subscription.renewalDuration
            );
            uint256 renewalFee = renewalPrice.add(protocolFee);
            if (subscription.deposit < renewalFee) {
                continue;
            }
            registrarController.renew{value: renewalPrice}(
                subscription.domainName,
                subscription.renewalDuration
            );
            subscription.deposit = subscription.deposit.sub(renewalFee);
            withdrawableProtocolFeePool = withdrawableProtocolFeePool.add(
                protocolFee
            );
            emit DomainSubscriptionRenewed(subscriptionId);
        }
    }
}
