import React, { useState } from 'react'
import { Button, Flex, Heading, Grid, GridItem, Input } from '@chakra-ui/react'
import { Control } from '@ui/components'

import { useStore } from '@ui/hooks'
import { topUpSubscription } from '@ui/features/subscriptionDetail'

export const baseInitialState = {
  amount: 0
}

export const TopUpSubscription = ({ id, asyncManager, store }) => {
  const _store = useStore({
    ...baseInitialState
  })

  const [validation, setValidation] = useState({})
  const { state, update } = _store

  const resetFormValidation = () => {
    setValidation({})
  }

  const isFormValid = () => {
    resetFormValidation()
    const invalidList = Object.keys(state).filter((name) => {
      if (
        (Array.isArray(state[name]) && state[name].length === 0) ||
        ((typeof state[name] === 'string' || state[name] instanceof String) &&
          state[name].trim().length === 0)
      ) {
        setValidation((state) => ({ ...state, [name]: 'Required Field' }))
        return true
      }
      return false
    })
    return invalidList.length === 0
  }

  const onTextChange = (key) => (e) => update({ [key]: e.target.value })

  const onSubmit = () => {
    if (isFormValid()) {
      topUpSubscription({
        subscriptionId: id,
        asyncManager,
        amount: state.amount,
        update: store.update
      })
    }
  }

  return (
    <>
      <Heading size="md" mb="6">
        Top Up Subscription
      </Heading>
      <Grid gap={3} mb={12}>
        <GridItem>
          <Control
            label="Amount"
            helper="In ETH"
            isInvalid={!!validation['amount']}
            errorMessage={validation['amount']}>
            <Input
              isInvalid={!!validation['amount']}
              type="text"
              placeholder="Name"
              value={state.amount}
              onChange={onTextChange('amount')}
            />
          </Control>
        </GridItem>
      </Grid>
      <Flex mt="2" justify="end">
        <Button
          variant="default"
          isDisabled={asyncManager.loading || asyncManager.pending}
          onClick={onSubmit}
          loadingText={
            asyncManager.pending
              ? 'Topping up subscription'
              : 'Waiting for confirmation'
          }>
          Top Up
        </Button>
      </Flex>
    </>
  )
}
