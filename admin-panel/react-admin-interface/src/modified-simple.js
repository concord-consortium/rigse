// in src/dataProvider.js
import { UPDATE, CREATE, GET_LIST, GET_ONE  } from 'ra-core';
import filterUpdateParams from './filterUpdateParams'

// We need to change the update and create args send to our GraphQL Backend
// specifically, we need to wrap our arguments in a `data` key when sending.
const customizeProvider = (baseProvider) => {
  return {
    // update: (resource, params) => {
    //   const { id, data } = params
    //   return baseProvider(UPDATE, resource, {
    //     data: {id, data: filterUpdateParams(resource, data)}
    //   })
    // },
    update: (resource, params) => baseProvider(UPDATE, resource, params),
    create: (resource, params)=> {
      const { data } = params
      return baseProvider(CREATE, resource, {
        data: {data: filterUpdateParams(resource, data)}
      })
    },
    getList: (resource, params) => baseProvider(GET_LIST, resource, params),
    getOne: (resource, params) => baseProvider(GET_ONE, resource, params)
  }
}


export default customizeProvider;