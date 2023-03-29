// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IENSExpirationManager} from "./interfaces/IENSExpirationManager.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ETHRegistrarController} from "@ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";
import {BaseRegistrarImplementation} from "@ens-contracts/contracts/ethregistrar/BaseRegistrarImplementation.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

contract ENSExpirationManager is
    IENSExpirationManager,
    AutomationCompatibleInterface,
    Pausable,
    ReentrancyGuard
{
    /// @dev The BaseRegistrarImplementation contract
    BaseRegistrarImplementation baseRegistrar;
    /// @dev The ETHRegistrarController contract
    ETHRegistrarController registrarController;
    IPriceOracle priceOracle;
    address public owner;
    address public keeperRegistryAddress;
    uint256 public protocolFee;
    uint256 public protocolFeePool;
    uint256 public withdrawableProtocolFeePool;
    uint256[] private subscriptionIds;
    /// @dev Mapping of tokenIds to the subscription
    mapping(uint256 => Subscription) public subscriptions;
    /// @dev Mapping of owner address to the amount of deposit
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public pendingWithdrawals;

    struct Subscription {
        address owner;
        string domainName;
        uint256 renewalDuration;
        uint256 renewalCount;
        uint256 renewedCount;
        uint256 gracePeriod;
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
        uint256 amount = withdrawableProtocolFeePool;
        withdrawableProtocolFeePool = 0;
        payable(msg.sender).transfer(amount);
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
     * @notice This method is called to get the owner of the ENS Domain
     */
    function _stringToTokenId(
        string memory _name
    ) private pure returns (uint256) {
        return uint256(keccak256(bytes(_name)));
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
     * @notice This method is called to get the protocol fee
     */
    function getProtocolFee() external view returns (uint256) {
        return protocolFee;
    }

    /**
     * @notice This method is called to get the balance of the protocol fee pool
     */
    function getProtocolFeePoolBalance() external view returns (uint256) {
        return protocolFeePool;
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
     * @notice This method is called to get the pending withdrawals amount
     */
    function getPendingWithdrawals(
        address _owner
    ) external view returns (uint256) {
        return pendingWithdrawals[_owner];
    }

    /**
     * @notice This method is called to get the total fee for a domain
     */
    function getTotalFee(
        string memory _domainName,
        uint256 _renewalDuration
    ) external view returns (uint256) {
        uint256 _tokenId = _stringToTokenId(_domainName);
        uint256 _currentExpiration = baseRegistrar.nameExpires(_tokenId);
        uint256 _price = priceOracle.price(
            _domainName,
            _currentExpiration,
            _renewalDuration
        );
        return _price + protocolFee;
    }

    /**
     * @notice This method is called to add subscriptions
     */
    function addSubscription(
        string memory _domainName,
        uint256 _renewalDuration,
        uint256 _renewalCount,
        uint256 _gracePeriod
    ) external payable nonReentrant {
        uint256 _tokenId = _stringToTokenId(_domainName);
        uint256 _currentExpiration = baseRegistrar.nameExpires(_tokenId);
        uint256 _price = priceOracle.price(
            _domainName,
            _currentExpiration,
            _renewalDuration
        );
        if (_getTokenOwner(_tokenId) != msg.sender) {
            revert InvalidOwner();
        }
        if (
            _currentExpiration - _gracePeriod <= block.timestamp ||
            _gracePeriod == 0
        ) {
            revert InvalidGracePeriod();
        }
        if (_renewalDuration < 28 * 24 * 60 * 60) {
            revert InvalidRenewalDuration();
        }
        if (_renewalCount < 1) {
            revert InvalidRenewalCount();
        }
        if (msg.value < (protocolFee + _price) * _renewalCount) {
            revert InsufficientFunds();
        }
        Subscription memory newSubscription = Subscription(
            msg.sender,
            _domainName,
            _renewalDuration,
            _renewalCount,
            0, // default to 0 renewals
            _gracePeriod
        );
        subscriptions[_tokenId] = newSubscription;
        subscriptionIds.push(_tokenId);
        deposits[msg.sender] += msg.value * _renewalCount;
        protocolFeePool += protocolFee * _renewalCount;
        emit DomainSubscriptionAdded(
            msg.sender,
            _domainName,
            _renewalDuration,
            _renewalCount,
            _gracePeriod
        );
    }

    /**
     * @notice This method is called to cancel and refund the subscription
     */
    function cancelSubscription(uint256 _tokenId) external nonReentrant {
        if (subscriptions[_tokenId].owner != msg.sender) {
            revert InvalidOwner();
        }
        uint256 _price = priceOracle.price(
            subscriptions[_tokenId].domainName,
            baseRegistrar.nameExpires(_tokenId),
            subscriptions[_tokenId].renewalDuration
        );
        // calculate number of refundable renewals
        uint256 refundableRenewals = subscriptions[_tokenId].renewalCount -
            subscriptions[_tokenId].renewedCount;

        deposits[msg.sender] -= _price * refundableRenewals;
        protocolFeePool -= protocolFee * refundableRenewals;
        pendingWithdrawals[msg.sender] +=
            (_price + protocolFee) *
            refundableRenewals;
        _deleteSubscription(_tokenId);
    }

    /**
     * @notice This method is called to withdraw the pending withdrawals
     */
    function withdrawPendingWithdrawals() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawals");
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit PendingWithdrawalsWithdrawn(msg.sender, amount);
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
                // Refund the deposit without the protocol fee as a penalty
                uint256 _tokenId = invalidSubscriptionsIds[i];
                uint256 _price = priceOracle.price(
                    subscriptions[_tokenId].domainName,
                    baseRegistrar.nameExpires(_tokenId),
                    subscriptions[_tokenId].renewalDuration
                );

                require(
                    deposits[subscriptions[_tokenId].owner] >= _price,
                    "Insufficient deposit"
                );

                deposits[subscriptions[_tokenId].owner] -= _price;
                pendingWithdrawals[subscriptions[_tokenId].owner] += _price;
                protocolFeePool -= protocolFee;
                withdrawableProtocolFeePool += protocolFee;
                _deleteSubscription(_tokenId);
            }
        }
        for (uint256 i = 0; i < expiredDomainSubscriptionIds.length; i++) {
            uint256 tokenId = expiredDomainSubscriptionIds[i];
            address owner = subscriptions[tokenId].owner;
            uint256 currentExpiration = baseRegistrar.nameExpires(tokenId);
            uint256 renewalPrice = priceOracle.price(
                subscriptions[tokenId].domainName,
                currentExpiration,
                subscriptions[tokenId].renewalDuration
            );
            registrarController.renew{value: renewalPrice}(
                subscriptions[tokenId].domainName,
                subscriptions[tokenId].renewalDuration
            );
            deposits[owner] -= renewalPrice;
            protocolFeePool -= protocolFee;
            withdrawableProtocolFeePool += protocolFee;
            subscriptions[tokenId].renewedCount++;
            emit DomainSubscriptionRenewed(tokenId);
            if (
                subscriptions[tokenId].renewedCount ==
                subscriptions[tokenId].renewalCount
            ) {
                _deleteSubscription(tokenId);
            }
        }
    }
}
