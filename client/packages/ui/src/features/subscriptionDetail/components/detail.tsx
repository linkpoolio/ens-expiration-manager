import React, { useEffect } from 'react'
import { useAccount } from 'wagmi'
import { useHistory } from 'react-router-dom'
import {
  Container,
  Heading,
  Center,
  Text,
  Box,
  Flex,
  useMediaQuery,
  Button,
  HStack,
  Tooltip
} from '@chakra-ui/react'

import { Error } from '@ui/components'
import { useAsyncManager, useStore } from '@ui/hooks'
import { shortenAddress } from '@ui/utils'
import {
  getSubscription,
  cancelSubscription,
  TopUpSubscriptionButton,
  StepManager
} from '@ui/features/subscriptionDetail'
import { convertUnixTimeToDuration } from '@ui/utils'

export const initialState = {
  subscription: null,
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
  const history = useHistory()
  const { subscription } = store.state
  const componentDidMount = () => {
    if (id)
      getSubscription({
        subscriptionId: id,
        update: store.update,
        asyncManager
      })
  }
  const onSubmit = () => {
    cancelSubscription({
      subscriptionId: id,
      asyncManager,
      history
    })
  }
  useEffect(componentDidMount, [])
  return (
    subscription?.subscriptionId && (
      <Container
        maxW="container.md"
        my="20"
        p="10"
        pb="24"
        bg="brand.white"
        boxShadow="brand.base"
        borderRadius="base">
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
            name="Renewal duration"
            value={convertUnixTimeToDuration(
              subscription.renewalDuration.toString()
            )}
          />
          <Row name="Deposit" value={`${subscription.deposit} ETH`} />
          <Row
            name="Owner"
            value={
              isLargerThanMd
                ? subscription.owner
                : shortenAddress(subscription.owner)
            }
          />
          <Center>
            <HStack spacing="6">
              <TopUpSubscriptionButton
                subscription={subscription}
                update={store.update}
                address={address}
              />
              <Tooltip
                hasArrow
                arrowSize={10}
                placement="top"
                label="Cancel your subscription and get your deposit back">
                <Button
                  variant="default"
                  onClick={onSubmit}
                  isLoading={asyncManager.loading || asyncManager.pending}
                  loadingText={
                    asyncManager.loading ? 'Submitting' : 'Pending Transaction'
                  }>
                  Cancel
                </Button>
              </Tooltip>
              <StepManager
                id={subscription.subscriptionId.toString()}
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
