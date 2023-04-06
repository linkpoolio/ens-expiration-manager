import { contracts } from '@ui/api'
import { Routes } from '@ui/Routes'

export const getSubscription = async ({
  subscriptionId,
  asyncManager,
  update
}) => {
  try {
    asyncManager.start()
    const subscription = await contracts.getSubscription({ subscriptionId })
    asyncManager.success()
    update({ subscription: { ...subscription } })
  } catch (error) {
    asyncManager.fail(
      `Could not get the subscription, please check your're connected to the correct network.`
    )
  }
}

export const cancelSubscription = async ({
  subscriptionId,
  asyncManager,
  history
}) => {
  try {
    asyncManager.start()
    const { wait } = await contracts.cancelSubscription({
      subscriptionId: subscriptionId
    })
    asyncManager.waiting()
    const isSuccess = await wait().then((receipt) => receipt.status === 1)
    if (!isSuccess)
      throw new Error('Request to add subscription was not successful')

    asyncManager.success()
    history.push({
      pathname: Routes.SubscriptionList,
      search: '?cancel-success'
    })
  } catch (error) {
    asyncManager.fail(`Could not cancel subscription.`)
  }
}

export const topUpSubscription = async ({
  subscriptionId,
  amount,
  asyncManager,
  update
}) => {
  try {
    const { wait } = await contracts.topUpSubscription({
      subscriptionId,
      amount
    })
    asyncManager.waiting()
    const isSuccess = await wait().then((receipt) => receipt.status === 1)
    if (!isSuccess) {
      throw new Error('Request to top up subscription was not successful')
    }
    await getSubscription({ subscriptionId, asyncManager, update })
    asyncManager.success()
  } catch (error) {
    asyncManager.fail(`Failed to top up subscription.`)
  }
}
