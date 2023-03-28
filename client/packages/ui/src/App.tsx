import React from 'react'
import { Switch, Redirect, Route } from 'react-router-dom'

import { Routes } from '@ui/Routes'
// import { RaffleList } from '@ui/features/raffleList'
// import { RaffleDetail } from '@ui/features/raffleDetail'
// import { RaffleCreate } from '@ui/features/raffleCreate'
import { Hero } from '@ui/components'
import { SubscriptionList } from './features/subscriptionList'
import { SubscriptionDetail } from './features/subscriptionDetail/components'

export const App = () => (
  <>
    <Switch>
      <Route
        exact
        path={Routes.SubscriptionList}
        render={(props) => (
          <>
            <Hero />
            <SubscriptionList {...props} />
          </>
        )}
      />

      <Route
        path={Routes.SubscriptionDetail}
        render={({ match }) => <SubscriptionDetail id={match.params.id} />}
      />

      {/* <Route exact path={Routes.RaffleCreate}>
        <AuthenticatedRoute connected={true}>
          <RaffleCreate />
        </AuthenticatedRoute>
      </Route> */}

      <Redirect to={Routes.SubscriptionList} />
    </Switch>
  </>
)
