// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IENSExpirationManager {
    event DomainSubscriptionAdded(
        address owner,
        string domainName,
        uint256 renewalDuration,
        uint256 renewalCount,
        uint256 gracePeriod
    );

    event DomainSubscriptionRenewed(uint256 _tokenId);

    event DomainSubscriptionRemoved(uint256 _tokenId);

    event DepositRefunded(
        address indexed _owner,
        uint256 _tokenId,
        uint256 _amount
    );

    event DomainSubscriptionsCheckCompleted(
        uint256[] expiredDomainSubscriptionIds,
        uint256[] invalidSubscriptionsIds
    );

    event PendingWithdrawalsWithdrawn(address indexed _owner, uint256 _amount);
    event ProtocolFeesWithdrawn(address indexed _owner, uint256 _amount);

    error ZeroAddress();
    error InvalidOwner();
    error OnlyKeeperRegistry();

    function setKeeperRegistryAddress(address _keeperAddress) external;

    function setRegistrarController(address _registrarController) external;

    function setBaseRegistrar(address _baseRegistrar) external;

    function setProtocolFee(uint256 _protocolFee) external;

    function addSubscription(
        string memory _domainName,
        uint256 _renewalDuration,
        uint256 _renewalCount,
        uint256 _gracePeriod
    ) external payable;

    function cancelSubscription(uint256 _tokenId) external;
}
