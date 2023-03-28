import { contracts } from '@ui/api'

export const addSubscription = async ({
  domain,
  renewalDuration,
  gracePeriod,
  asyncManager
}) => {
  try {
    asyncManager.start()
    const fee = await contracts.getTotalFee({ domain, renewalDuration })
    const { wait } = await contracts.addSubscription({
      domain,
      renewalDuration,
      gracePeriod,
      fee
    })
    asyncManager.waiting()

    const isSuccess = await wait().then((receipt) => receipt.status === 1)

    if (!isSuccess)
      throw new Error('Request to add subscription was not successful')

    asyncManager.success()
  } catch (error) {
    asyncManager.fail(`Could not add subscription.`)
  }
}
