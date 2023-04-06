import { contracts } from '@ui/api'
import { Routes } from '@ui/Routes'

export const addSubscription = async ({ state, asyncManager, history }) => {
  try {
    asyncManager.start()
    const { wait } = await contracts.addSubscription({
      ...state,
      domain: state.domain,
      renewalDuration: state.renewalDuration * 86400, // 1 day
      deposit: state.deposit,
      gracePeriod: 86400 // 1 day
    })
    asyncManager.waiting()

    const isSuccess = await wait().then((receipt) => receipt.status === 1)

    if (!isSuccess)
      throw new Error('Request to add subscription was not successful')

    asyncManager.success()

    history.push({
      pathname: Routes.SubscriptionList,
      search: '?create-success'
    })
  } catch (error) {
    asyncManager.fail(`Could not add subscription.`)
  }
}
