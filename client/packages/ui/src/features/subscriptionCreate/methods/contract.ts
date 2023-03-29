import { contracts } from '@ui/api'
import { Routes } from '@ui/Routes'

export const addSubscription = async ({ state, asyncManager, history }) => {
  try {
    asyncManager.start()
    // const totalbaseFee = await contracts.getTotalFee({
    //   domain: state.domain,
    //   renewalDuration: state.renewalDuration
    // })
    // console.log({ totalbaseFee })
    const { wait } = await contracts.addSubscription({
      ...state,
      fee: 100767123285644800 * state.renewalCount
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
