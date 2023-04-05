import { SubscriptionInstance } from './types'
import { ethers, BigNumber } from 'ethers'

export const transformSubscription = (subscription): SubscriptionInstance => {
  try {
    const tokenId = BigNumber.from(
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes(subscription[1]))
    ).toString()
    return {
      owner: subscription[0],
      domain: subscription[1],
      subscriptionId: ethers.BigNumber.from(
        ethers.utils.keccak256(
          ethers.utils.solidityPack(
            ['uint256', 'address'],
            [tokenId, subscription[0]]
          )
        )
      ),
      renewalDuration: subscription[2],
      gracePeriod: subscription[3],
      deposit: ethers.utils.formatEther(subscription[4].toString()),
      state: subscription[5]
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
