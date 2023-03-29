import React, { useState, useEffect } from 'react'
import { useHistory } from 'react-router-dom'
import { useAccount } from 'wagmi'
import {
  Container,
  Heading,
  Center,
  Input,
  Grid,
  GridItem,
  Button
} from '@chakra-ui/react'

import { Routes } from '@ui/Routes'
import { Error, Control } from '@ui/components'
import { useAsyncManager, useStore } from '@ui/hooks'
import { addSubscription } from '../methods'

export const baseInitialState = {
  domain: '',
  renewalDuration: 2419200,
  renewalCount: 1,
  gracePeriod: 604800
}

export const SubscriptionCreate = () => {
  const { address } = useAccount()

  const store = useStore({
    ...baseInitialState
  })

  const asyncManager = useAsyncManager()
  const history = useHistory()
  const [validation, setValidation] = useState({})

  const { state, update } = store

  const componentDidMount = () => {
    if (!address) history.push(Routes.SubscriptionList)
  }

  const componentDidUnmount = () => store.reset()

  useEffect(componentDidMount, [])
  useEffect(componentDidUnmount, [])

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
      addSubscription({ state, asyncManager, history })
    }
  }

  return (
    <Container
      maxW="container.xl"
      my="20"
      p="10"
      pb="24"
      bg="brand.white"
      boxShadow="brand.base"
      borderRadius="base">
      <Error asyncManager={asyncManager} />

      <Center flexDirection="column" mb="14">
        <Heading size="2xl" fontWeight="700" mb="6">
          Add Subscription
        </Heading>
      </Center>
      <Grid templateColumns="repeat(3, 1fr)" gap={14} rowGap={14} mb={12}>
        <GridItem>
          <Control
            label="Domain name"
            helper="Without .eth prefix"
            isInvalid={!!validation['domain']}
            errorMessage={validation['domain']}>
            <Input
              isInvalid={!!validation['domain']}
              type="text"
              placeholder="Name"
              value={state.domain}
              onChange={onTextChange('domain')}
            />
          </Control>
        </GridItem>

        <GridItem>
          <Control
            label="Renewal Duration"
            helper="In seconds (default: 2419200)"
            isInvalid={!!validation['renewalDuration']}
            errorMessage={validation['renewalDuration']}>
            <Input
              isInvalid={!!validation['renewalDuration']}
              type="text"
              placeholder="Number"
              value={state.renewalDuration}
              onChange={onTextChange('renewalDuration')}
            />
          </Control>
        </GridItem>

        <GridItem>
          <Control
            label="Renewal Count"
            helper="Number of renewals (default: 1)"
            isInvalid={!!validation['renewalCount']}
            errorMessage={validation['renewalCount']}>
            <Input
              isInvalid={!!validation['renewalCount']}
              type="text"
              placeholder="Number"
              value={state.renewalCount}
              onChange={onTextChange('renewalCount')}
            />
          </Control>
        </GridItem>

        <GridItem>
          <Control
            label="Grace Period"
            helper="In seconds (default: 604800)"
            isInvalid={!!validation['gracePeriod']}
            errorMessage={validation['gracePeriod']}>
            <Input
              isInvalid={!!validation['gracePeriod']}
              type="text"
              placeholder="Number"
              value={state.gracePeriod}
              onChange={onTextChange('gracePeriod')}
            />
          </Control>
        </GridItem>
      </Grid>
      <Center>
        <Button
          variant="default"
          onClick={onSubmit}
          isLoading={asyncManager.loading || asyncManager.pending}
          loadingText={
            asyncManager.loading ? 'Submitting' : 'Pending Transaction'
          }>
          Create
        </Button>
      </Center>
    </Container>
  )
}
