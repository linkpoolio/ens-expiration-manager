import React from 'react'
import { Switch, Redirect, Route } from 'react-router-dom'

import { Routes } from '@ui/Routes'
import { Hero, AuthenticatedRoute } from '@ui/components'
import { SubscriptionCreate } from './features/subscriptionCreate/components'
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

      <Route exact path={Routes.SubscriptionCreate}>
        <AuthenticatedRoute connected={true}>
          <SubscriptionCreate />
        </AuthenticatedRoute>
      </Route>

      <Redirect to={Routes.SubscriptionList} />
    </Switch>
  </>
)
