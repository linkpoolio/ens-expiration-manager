import React from 'react'
import { Button } from '@chakra-ui/react'

import { steps } from '@ui/features/subscriptionDetail'

const onCancelSubscription = ({ update }) => update({ step: steps.CANCEL })

export const CancelSubscriptionButton = ({ update }) => {
  return (
    <Button onClick={() => onCancelSubscription({ update })} variant="default">
      Cancel Subscription
    </Button>
  )
}
