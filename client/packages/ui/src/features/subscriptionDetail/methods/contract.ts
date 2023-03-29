import { contracts } from '@ui/api'

export const getSubscription = async ({ tokenId, asyncManager, update }) => {
  try {
    asyncManager.start()
    const expirationDate = await contracts.getExpirationDate({ tokenId })
    const subscription = await contracts.getSubscription({ tokenId })
    asyncManager.success()
    update({ subscription: { ...subscription, expirationDate } })
  } catch (error) {
    asyncManager.fail(
      `Could not get the subscription, please check your're connected to the correct network.`
    )
  }
}

export const cancelSubscription = async ({ domain, asyncManager, success }) => {
  try {
    asyncManager.start()
    const { wait: cancelWait } = await contracts.cancelSubscription({
      tokenId: domain
    })
    asyncManager.waiting()
    const cancelIsSuccess = await cancelWait().then(
      (receipt) => receipt.status === 1
    )
    if (cancelIsSuccess) {
      const { wait: withdrawWait } =
        await contracts.withdrawPendingWithdrawals()
      asyncManager.waiting()
      const withdrawIsSuccess = await withdrawWait().then(
        (receipt) => receipt.status === 1
      )
      if (!withdrawIsSuccess)
        throw new Error('Request to cancel the subscription was not successful')
      asyncManager.success()
      success(true)
    }
  } catch (error) {
    asyncManager.fail(`Could not cancel subscription.`)
  }
}
