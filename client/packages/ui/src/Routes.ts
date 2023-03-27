export const Routes = {
  RaffleList: '/',
  RaffleDetail: '/raffle/:id',
  RaffleCreate: '/create'
}

export const createRoute = ({ route, id }) => route.replace(':id', id)
