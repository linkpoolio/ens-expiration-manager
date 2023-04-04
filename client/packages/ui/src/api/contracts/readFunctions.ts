import { readContract } from '@wagmi/core'
import { env } from '@ui/config'
import {
  transformSubscriptions,
  transformSubscription,
  SubscriptionInstance
} from '@ui/models'
import { contracts } from '@ui/api'
import ensExpirationManagerABI from './abi/ENSExpirationManager.json'
import ensBaseRegistrarABI from './abi/ENSBaseRegistrar.json'
import { BigNumber } from 'ethers'

// TODO: REMOVE THIS
const ensExpirationManagerContractAddress =
  env.ensExpirationManagerContractAddress() ||
  '0x0956550D0041eBD3fFe4fa939Fce0d6e3dE3fB9d'

const ensENSBaseRegistrarContractAddress =
  env.ensENSBaseRegistrarContractAddress() ||
  '0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85'

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
      `Error fetching subscriptions list from contract: ${error.message}`
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
      `Error fetching subscriptions list from contract: ${error.message}`
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
      `Error fetching subscriptions list from contract: ${error.message}`
    )
  }
}

export const getExpirationDate = async (
  params: contracts.GetExpirationDateParams
): Promise<number> => {
  try {
    const data = await readContract({
      abi: ensBaseRegistrarABI,
      address: ensENSBaseRegistrarContractAddress,
      functionName: 'nameExpires',
      args: [params.tokenId]
    })
    return Number(data)
  } catch (error: any) {
    throw new Error(
      `Error fetching subscriptions list from contract: ${error.message}`
    )
  }
}
