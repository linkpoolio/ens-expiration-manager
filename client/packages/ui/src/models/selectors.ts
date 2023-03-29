import { SubscriptionInstance } from '@ui/models'

export const filterSusbscriptionList = (
  list,
  filters
): SubscriptionInstance[] =>
  list.filter((subscription) => filters.every((filter) => filter(subscription)))

export const isSubscriptionOwner = (subscription, address) =>
  subscription.owner === address
