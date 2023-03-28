import { prepareWriteContract, writeContract } from '@wagmi/core'

import { env } from '@ui/config'
import { contracts } from '@ui/api'
import abi from './abi/ENSExpirationManager.json'

const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress()

export const addSubscription = async (
  params: contracts.AddSubscriptionParams
) => {
  try {
    const config = await prepareWriteContract({
      address: ensExpirationManagerContractAddress,
      abi,
      overrides: {
        value: params.fee
      },
      functionName: 'addSubscription',
      args: [params.domain, params.renewalDuration, params.gracePeriod]
    })
    const data = await writeContract(config)
    return data
  } catch (error: any) {
    throw new Error(`Error creating subscription: ${error.message}`)
  }
}

export const cancelSubscription = async (
  params: contracts.CancelSubscriptionParams
) => {
  try {
    const config = await prepareWriteContract({
      address: ensExpirationManagerContractAddress,
      abi,
      functionName: 'cancelSubscription',
      args: [params.tokenId]
    })
    const data = await writeContract(config)
    return data
  } catch (error: any) {
    throw new Error(`Error cancelling subscription: ${error.message}`)
  }
}

export const withdrawPendingWithdrawals = async () => {
  try {
    const config = await prepareWriteContract({
      address: ensExpirationManagerContractAddress,
      abi,
      functionName: 'withdrawPendingWithdrawals'
    })
    const data = await writeContract(config)
    return data
  } catch (error: any) {
    throw new Error(`Error withdrawing pending withdrawals: ${error.message}`)
  }
}
