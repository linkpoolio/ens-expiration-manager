export const Routes = {
  SubscriptionList: '/',
  SubscriptionDetail: '/subscription/:id',
  SubscriptionCreate: '/create'
}

export const createRoute = ({ route, subscriptionId }) =>
  route.replace(':id', subscriptionId)
