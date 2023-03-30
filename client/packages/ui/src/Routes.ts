export const Routes = {
  SubscriptionList: '/',
  SubscriptionDetail: '/subscription/:id',
  SubscriptionCreate: '/create'
}

export const createRoute = ({ route, id }) => route.replace(':id', id)
