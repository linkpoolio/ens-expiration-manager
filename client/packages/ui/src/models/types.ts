import { BigNumber } from 'ethers'

export interface SubscriptionInstance {
  owner: string
  domain: string
  tokenId: string
  renewalDuration: BigNumber
  renewalCount: number
  renewedCount: number
  gracePeriod: BigNumber
}
