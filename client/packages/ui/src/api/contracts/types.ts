export interface AddSubscriptionParams {
  domain: string
  renewalDuration: number
  renewalCount: number
  gracePeriod: number
  fee: number
}

export interface CancelSubscriptionParams {
  tokenId: string
}

export interface GetRenewalPriceParams {
  domain: string
  renewalDuration: number
}

export interface GetSubscriptionParams {
  tokenId: string
}

export interface GetExpirationDateParams {
  tokenId: string
}
