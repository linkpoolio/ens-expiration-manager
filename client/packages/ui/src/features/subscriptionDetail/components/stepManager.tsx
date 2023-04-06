import React from 'react'

import { Error, Loading, Pending, Modal } from '@ui/components'
import { useAsyncManager } from '@ui/hooks'
import { TopUpSubscription } from '@ui/features/subscriptionDetail'
import { steps } from '@ui/features/subscriptionDetail'

const getComponent = (props) => {
  switch (props.store.state.step) {
    case steps.TOPUP_SUBSCRIPTION:
      return <TopUpSubscription {...props} />
    default:
      return null
  }
}

export const StepManager = ({ id, store, address, subscription }) => {
  const asyncManager = useAsyncManager()
  const { step } = store.state

  const reset = (_store) => _store.update({ step: null })

  return (
    <Modal onClose={() => reset(store)} isOpen={!!step}>
      <Loading asyncManager={asyncManager} />
      <Pending asyncManager={asyncManager} />
      <Error asyncManager={asyncManager} />
      {getComponent({
        id,
        address,
        store,
        asyncManager,
        reset,
        subscription
      })}
    </Modal>
  )
}
