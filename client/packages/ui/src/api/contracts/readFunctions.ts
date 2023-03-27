import { readContract } from '@wagmi/core'

import { env } from '@ui/config'

import abi from './abi/ENSExpirationManager.json'
import { contracts } from '@ui/api'

const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress()
const defaultOptions = { abi, watch: true }

export const getAllRaffles = async (): Promise<
  contracts.SubscriptionInstance[]
> => {
  try {
    const data = await readContract({
      ...defaultOptions,
      address: ensExpirationManagerContractAddress,
      functionName: 'getAllSubscriptions'
    })
    return data
  } catch (error: any) {
    throw new Error(
      `Error fetching raffles list from contract: ${error.message}`
    )
  }
}
