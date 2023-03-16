// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IENSExpirationManager {
    event DomainSubscriptionAdded(
        address owner,
        string domainName,
        uint256 renewalDuration,
        uint256 gracePeriod
    );

    event DomainSubscriptionRenewed(uint256 tokenId);

    event DomainSubscriptionRemoved(uint256 tokenId);

    event DomainSubscriptionExpired(uint256 tokenId);

    event DepositToppedUp(address indexed owner, uint256 amount);
    event DepositWithdrawn(address indexed owner, uint256 amount);

    error ZeroAddress();
    error InvalidWithdrawAmount();
    error InvalidTopUpAmount();
    error InvalidOwner();
    error DomainAlreadyExpired();
    error InvalidGracePeriod();
    error InvalidRenewalDuration();
    error InvalidSubscriptionsLength();
    error NotOwnerOfSubscription();
    error InsufficientDeposit();
    error OnlyKeeperRegistry();
    error InvalidSubscriptionId();

    function setKeeperRegistryAddress(address _keeperAddress) external;

    function setRegistrarController(address _registrarController) external;

    function setBaseRegistrar(address _baseRegistrar) external;

    function setProtocolFee(uint256 _protocolFee) external;

    function topUpDeposit() external payable;

    function withdrawDeposit(uint256 _amount) external;

    function addSubscriptions(
        string[] memory _domainNames,
        uint256[] memory _renewalDurations,
        uint256[] memory _gracePeriods
    ) external;

    function removeSubscriptions(uint256[] calldata _subscriptionIds) external;
}
