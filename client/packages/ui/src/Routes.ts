export const Routes = {
  SubscriptionList: '/',
  SubscriptionDetail: '/raffle/:id',
  SubscriptionCreate: '/create'
}

export const createRoute = ({ route, id }) => route.replace(':id', id)
