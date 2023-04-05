import React, { useEffect } from 'react'
import { useAccount } from 'wagmi'
import { Switch, FormLabel, HStack, Box, Flex } from '@chakra-ui/react'
import { SubscriptionState } from '@ui/models'

export const initialFilterState = {
  ownedByMe: true,
  status: ''
}

export const filterList = (filters, address) => (Subscription) => {
  const ownedByMe = !filters.ownedByMe || Subscription.owner == address
  const stateEqualsOne = Subscription.state === SubscriptionState.ACTIVE

  return ownedByMe && stateEqualsOne
}

export const Filters = ({ store }) => {
  const { address } = useAccount()

  const { state, update, reset } = store

  const onFilterOwnedByMe = () => update({ ownedByMe: !state.ownedByMe })

  const componentDidUnmount = () => reset()
  useEffect(componentDidUnmount, [])

  return (
    <>
      <Box my="8">
        <HStack spacing="24px">
          {address && (
            <Flex align="center">
              <FormLabel htmlFor="ownerd-by-me" mb="0" w="105px">
                Owned by Me
              </FormLabel>
              <Switch
                id="ownerd-by-me"
                checked={state.ownedByMe}
                onChange={onFilterOwnedByMe}
              />
            </Flex>
          )}
        </HStack>
      </Box>
    </>
  )
}
