import { BigNumber } from 'ethers'

export interface SubscriptionInstance {
  owner: string
  domain: string
  subscriptionId: BigNumber
  renewalDuration: BigNumber
  gracePeriod: BigNumber
  deposit: string
  state: SubscriptionState
}
export enum SubscriptionState {
  CANCELLED,
  ACTIVE
}
