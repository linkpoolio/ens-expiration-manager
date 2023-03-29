import React, { useState, useEffect } from 'react'
import { Button, Text, Flex, Heading } from '@chakra-ui/react'

import { cancelSubscription } from '@ui/features/subscriptionDetail'

export const CancelSubscription = ({ id, reset, asyncManager, store }) => {
  const [cancelSuccess, setCancelSuccess] = useState(false)

  const componentDidMount = () => {
    cancelSubscription({
      domain: id,
      success: setCancelSuccess,
      asyncManager
    })
  }
  useEffect(componentDidMount, [])

  return (
    cancelSuccess && (
      <>
        <Heading size="md" mb="6">
          Cancel subscription
        </Heading>
        <Text>Successfully cancelled subscription for token `{id}`.</Text>
        <Flex mt="2" justify="end">
          <Button variant="default" onClick={() => reset(store)}>
            Close
          </Button>
        </Flex>
      </>
    )
  )
}
