import { readContract } from '@wagmi/core'
import { env } from '@ui/config'
import {
  transformSubscriptions,
  transformSubscription,
  SubscriptionInstance
} from '@ui/models'
import { contracts } from '@ui/api'
import ensExpirationManagerABI from './abi/ENSExpirationManager.json'
import { BigNumber } from 'ethers'

const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress() ||
  '0xd5Fbe74B04881eFD23aB2A281491CF3be4165a2E'

export const getAllSubscriptions = async (): Promise<
  SubscriptionInstance[]
> => {
  try {
    const data = await readContract({
      abi: ensExpirationManagerABI,
      address: ensExpirationManagerContractAddress,
      functionName: 'getAllSubscriptions'
    })
    return transformSubscriptions(data)
  } catch (error: any) {
    throw new Error(
      `Error fetching raffles list from contract: ${error.message}`
    )
  }
}

export const getSubscription = async (
  params: contracts.GetSubscriptionParams
): Promise<SubscriptionInstance> => {
  try {
    const data = await readContract({
      abi: ensExpirationManagerABI,
      address: ensExpirationManagerContractAddress,
      functionName: 'getSubscription',
      args: [BigNumber.from(params.tokenId)]
    })
    return transformSubscription(data)
  } catch (error: any) {
    throw new Error(
      `Error fetching raffles list from contract: ${error.message}`
    )
  }
}

export const getTotalFee = async (
  params: contracts.GetRenewalPriceParams
): Promise<number> => {
  try {
    const data = await readContract({
      abi: ensExpirationManagerABI,
      address: ensExpirationManagerContractAddress,
      functionName: 'getTotalFee',
      args: [params.domain, params.renewalDuration]
    })
    return Number(data)
  } catch (error: any) {
    throw new Error(
      `Error fetching raffles list from contract: ${error.message}`
    )
  }
}