import { createNetworkInterface } from 'react-apollo';

export default {
  client: {
    networkInterface: createNetworkInterface({
        uri: 'http://localhost:4000/',
    })
  }
}
