export interface AddSubscriptionParams {
  domain: string
  renewalDuration: number
  gracePeriod: number
  deposit: number
}

export interface CancelSubscriptionParams {
  subscriptionId: string
}

export interface GetRenewalPriceParams {
  domain: string
  renewalDuration: number
}

export interface GetSubscriptionParams {
  subscriptionId: string
}

export interface GetExpirationDateParams {
  tokenId: string
}

export interface TopUpSubscriptionParams {
  subscriptionId: string
  amount: number
}
