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

    event DomainSubscriptionExpired(uint256 _tokenId);

    event DepositToppedUp(address indexed _owner, uint256 _amount);
    event DepositWithdrawn(address indexed _owner, uint256 _amount);
    event PendingWithdrawalsWithdrawn(address indexed _owner, uint256 _amount);

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
    error InsufficientFunds();
    error InvalidRenewalCount();

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
