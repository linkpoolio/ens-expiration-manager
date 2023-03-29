import React, { useEffect } from 'react'
import { useAccount } from 'wagmi'
import {
  Container,
  Heading,
  Center,
  Text,
  Box,
  Flex,
  useMediaQuery,
  HStack
} from '@chakra-ui/react'

import { Loading, Pending, Error } from '@ui/components'
import { useAsyncManager, useStore } from '@ui/hooks'
import { shortenAddress } from '@ui/utils'
import { getSubscription } from '@ui/features/subscriptionDetail'
import { convertUnixTimeToDuration, formatUnixTs } from '@ui/utils'
import {
  StepManager,
  CancelSubscriptionButton
} from '@ui/features/subscriptionDetail'

export const initialState = {
  subscription: null,
  step: null,
  identifier: null,
  participantStatus: null,
  isParticipant: null,
  claimableLink: null,
  participants: [],
  expirationDate: null
}

const Row = ({ name, value }) => {
  return (
    <Flex
      justifyContent="space-between"
      borderBottom="1px"
      borderColor="brand.gray_10"
      pb="6"
      my="6">
      <Text>{name}</Text>
      <Text>{value}</Text>
    </Flex>
  )
}

export const SubscriptionDetail = ({ id }) => {
  const [isLargerThanMd] = useMediaQuery('(min-width: 48em)')
  const { address } = useAccount()
  const store = useStore({
    ...initialState,
    identifier: address ? address : initialState.identifier
  })
  const asyncManager = useAsyncManager()

  const { subscription } = store.state
  const componentDidMount = () => {
    if (id) getSubscription({ tokenId: id, update: store.update, asyncManager })
  }
  useEffect(componentDidMount, [])
  return (
    subscription?.tokenId && (
      <Container
        maxW="container.md"
        my="20"
        p="10"
        pb="24"
        bg="brand.white"
        boxShadow="brand.base"
        borderRadius="base">
        <Loading asyncManager={asyncManager} />
        <Pending asyncManager={asyncManager} />
        <Error asyncManager={asyncManager} />
        <Center flexDirection="column" mb="6">
          <Heading
            size="xl"
            fontWeight="700"
            mb="6"
            wordBreak={'break-all'}
            textAlign="center">
            {subscription.domain}
          </Heading>
        </Center>

        <Box>
          <Row name="Name" value={subscription.domain} />
          <Row
            name="Renewal Date"
            value={formatUnixTs(
              subscription.expirationDate - subscription.gracePeriod
            )}
          />
          <Row
            name="Available renewals"
            value={subscription.renewalCount - subscription.renewedCount}
          />
          <Row
            name="Renewal duration"
            value={convertUnixTimeToDuration(
              subscription.renewalDuration.toString()
            )}
          />
          <Row
            name="Owner"
            value={
              isLargerThanMd
                ? subscription.owner
                : shortenAddress(subscription.owner)
            }
          />
          <Center h="60px"></Center>
          <Center>
            <HStack spacing="6">
              {address && address === subscription.owner && (
                <CancelSubscriptionButton update={store.update} />
              )}
              <StepManager
                id={id}
                store={store}
                address={address}
                subscription={subscription}
              />
            </HStack>
          </Center>
        </Box>
      </Container>
    )
  )
}
