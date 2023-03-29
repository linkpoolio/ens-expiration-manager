import { SubscriptionInstance } from './types'
import { ethers, BigNumber } from 'ethers'

export const transformSubscription = (subscription): SubscriptionInstance => {
  try {
    return {
      owner: subscription[0],
      domain: subscription[1],
      tokenId: BigNumber.from(
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes(subscription[1]))
      ).toString(),
      renewalDuration: subscription[2],
      renewalCount: subscription[3],
      renewedCount: subscription[4],
      gracePeriod: subscription[5]
    }
  } catch (error: any) {
    throw new Error(`Error transforming subscription: ${error.message}`)
  }
}

export const transformSubscriptions = (
  subscriptions
): SubscriptionInstance[] => {
  try {
    return subscriptions.map((subscription) =>
      transformSubscription(subscription)
    )
  } catch (error: any) {
    throw new Error(`Error transforming subscriptions: ${error.message}`)
  }
}
