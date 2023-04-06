import React from 'react'
import { Button, Tooltip } from '@chakra-ui/react'

import { steps } from '@ui/features/subscriptionDetail'

const onCancelClick = ({ update }) => update({ step: steps.TOPUP_SUBSCRIPTION })

export const TopUpSubscriptionButton = ({ update }) => (
  <Tooltip
    hasArrow
    arrowSize={10}
    placement="top"
    label="Top up your subscription with ETH when it's running low">
    <Button onClick={() => onCancelClick({ update })} variant="default">
      Top Up
    </Button>
  </Tooltip>
)
