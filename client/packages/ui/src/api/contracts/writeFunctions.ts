import { prepareWriteContract, writeContract } from '@wagmi/core'

import { env } from '@ui/config'
import { contracts } from '@ui/api'
import abi from './abi/ENSExpirationManager.json'
import { BigNumber } from 'ethers'

// TODO: REMOVE THIS
const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress() ||
  '0x0956550D0041eBD3fFe4fa939Fce0d6e3dE3fB9d'

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
