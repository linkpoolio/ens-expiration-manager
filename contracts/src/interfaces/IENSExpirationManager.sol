// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IENSExpirationManager {
    event DomainSubscriptionAdded(uint256 subscriptionId);

    event DomainSubscriptionRenewed(uint256 _subscriptionId);

    event DomainSubscriptionRemoved(uint256 _subscriptionId);

    event DomainSubscriptionCancelled(uint256 _subscriptionId);

    event DomainSubscriptionTopUp(uint256 _subscriptionId, uint256 _value);

    event DepositRefunded(
        address indexed _owner,
        uint256 _subscriptionId,
        uint256 _amount
    );

    event DomainSubscriptionsCheckCompleted(
        uint256[] expiredDomainSubscriptionIds
    );

    event DomainSubscriptionUpdated(uint256 _subscriptionId);

    event PendingWithdrawalsWithdrawn(address indexed _owner, uint256 _amount);
    event ProtocolFeesWithdrawn(address indexed _owner, uint256 _amount);

    error ZeroAddress();
    error InvalidOwner();
    error OnlyKeeperRegistry();
    error SubscriptionExists();

    function setKeeperRegistryAddress(address _keeperAddress) external;

    function setRegistrarController(address _registrarController) external;

    function setBaseRegistrar(address _baseRegistrar) external;

    function setProtocolFee(uint256 _protocolFee) external;

    function addSubscription(
        string memory _domainName,
        uint256 _renewalDuration,
        uint256 _gracePeriod
    ) external payable;

    function cancelSubscription(uint256 _subscriptionId) external;
}
