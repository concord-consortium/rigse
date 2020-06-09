// in src/App.js
import React, { Component } from 'react';
import buildGraphQLProvider, { buildQuery as buildQueryFactory } from 'ra-data-graphql-simple';

// import customizeProvider from './modified-simple'
import { Admin, Resource } from 'react-admin';
import { UserEdit, UserList, UserCreate } from './user'
import { ProjectList, ProjectCreate, ProjectEdit } from './project'
import { ProjectUserCreate, ProjectUserEdit } from './projectUser'

import { ApolloClient } from 'apollo-client';
import { createHttpLink } from 'apollo-link-http';
import { setContext } from 'apollo-link-context';
import { InMemoryCache } from 'apollo-cache-inmemory';

import MyLoginPage  from './myLoginPage'
import {authProvider, currentJwt} from './portalAuthProvider.ts'

const uri = 'http://localhost:4000/graphql';
const httpLink = createHttpLink({uri});
const customBuildQuery = introspectionResults => {
  console.info("ra-data-graphql introspectionResults:\n%O", introspectionResults);
  return buildQueryFactory(introspectionResults);
};

const authLink = setContext((_, { headers }) => {
  return {
      headers: {
          ...headers,
          authorization: currentJwt ? `Bearer ${currentJwt}` : "",
      }
  }
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
});

class App extends Component {
  constructor() {
    super();
    this.state = { dataProvider: null };
  }
  componentDidMount() {
    buildGraphQLProvider({
      buildQuery: customBuildQuery,
      client: client
    })
    .then(provider => {
      const loggingProvider = (type, resource, params) => {
        return provider(type, resource, params).then(result => {
          console.info("%s - %s\n  params:%O\n  result:%O",
            type, resource, params, result);
          return result;
        });
      }
      // const myProvider = customizeProvider(loggingProvider)
      this.setState({dataProvider: loggingProvider})
    })
  }

  render() {
    const { dataProvider } = this.state;

    if (!dataProvider) {
      return <div>Loading</div>;
    }

    return (
      <Admin dataProvider={dataProvider} authProvider={authProvider} loginPage={MyLoginPage}>
        <Resource name="User" list={UserList} edit={UserEdit} create={UserCreate} />
        <Resource name="AdminProject" list={ProjectList} edit={ProjectEdit} create={ProjectCreate}/>
        <Resource name="AdminProjectUser" edit={ProjectUserEdit} create={ProjectUserCreate}/>
      </Admin>
    );
  }
}
export default App;
