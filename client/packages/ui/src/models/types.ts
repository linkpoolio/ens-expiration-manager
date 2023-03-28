import { BigNumber } from 'ethers'

export interface SubscriptionInstance {
  owner: string
  domain: string
  tokenId: string
  renewalDuration: BigNumber
  gracePeriod: BigNumber
}
