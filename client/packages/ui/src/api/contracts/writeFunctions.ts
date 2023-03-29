import { prepareWriteContract, writeContract } from '@wagmi/core'

import { env } from '@ui/config'
import { contracts } from '@ui/api'
import abi from './abi/ENSExpirationManager.json'
import { BigNumber } from 'ethers'

// TODO: REMOVE THIS
const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress() ||
  '0xd5Fbe74B04881eFD23aB2A281491CF3be4165a2E'

export const addSubscription = async (
  params: contracts.AddSubscriptionParams
) => {
  try {
    const config = await prepareWriteContract({
      address: ensExpirationManagerContractAddress,
      abi,
      functionName: 'addSubscription',
      overrides: {
        value: BigNumber.from(params.fee.toString())
      },
      args: [
        params.domain,
        params.renewalDuration,
        params.renewalCount,
        params.gracePeriod
      ]
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
