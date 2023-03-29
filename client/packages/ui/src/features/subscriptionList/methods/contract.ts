import { contracts } from '@ui/api'

export const getSubscriptionList = async ({ asyncManager, update }) => {
  try {
    asyncManager.start()

    const list = await contracts.getAllSubscriptions()
    asyncManager.success()
    update({ list })
  } catch (error) {
    asyncManager.fail(
      `Could not get subscription list, please check your're connected to the correct network.`
    )
  }
}
