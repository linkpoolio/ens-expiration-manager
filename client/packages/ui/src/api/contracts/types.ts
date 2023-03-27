import { BigNumber } from 'ethers'

export interface AddSubscriptionParams {
  domainName: string
  renewalDuration: number
  gracePeriod: number
  fee: number
}

export interface CancelSubscriptionParams {
  tokenId: number
}

export interface SubscriptionInstance {
  owner: string
  domainName: string
  renewalDuration: BigNumber
  gracePeriod: BigNumber
}
