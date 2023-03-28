import { contracts } from '@ui/api'
import { ethers, BigNumber } from 'ethers'

export const getSubscription = async ({ tokenId, asyncManager, update }) => {
  try {
    asyncManager.start()
    const subscription = await contracts.getSubscription({ tokenId })
    asyncManager.success()
    update({ subscription })
  } catch (error) {
    asyncManager.fail(
      `Could not get the subscription, please check your're connected to the correct network.`
    )
  }
}

export const cancelSubscription = async ({ domain, asyncManager }) => {
  try {
    asyncManager.start()
    const tokenId = BigNumber.from(
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes(domain))
    ).toString()
    const { wait } = await contracts.cancelSubscription({ tokenId })
    asyncManager.waiting()
    const isSuccess = await wait().then((receipt) => receipt.status === 1)
    if (!isSuccess)
      throw new Error('Request to cancel the subscription was not successful')
    asyncManager.success()
  } catch (error) {
    asyncManager.fail(`Could not cancel subscription.`)
  }
}
