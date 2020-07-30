# Administration Interface

As of June 2020 we are migrating some administrational functions to a new
technology stack. The back-end uses [TypeORM](https://typeorm.io/#/) to connect
to the Portal's database and provides a [GraphQL](https://graphql.org/) API using
[TypeGraphQL](https://typegraphql.com/).
The front end uses [ReactAdmin](https://marmelab.com/react-admin/) to provide
a [Material UI](https://material-ui.com/) interface for administrators.

The goals for this work are described in this document:
[Portal Admin design](https://docs.google.com/document/d/1uq8jXhpw96FYXn2dqNZIl1XUjVc3S3h2P2lfD7RMoUw/edit).

Admin panel work is in the
`./admin-panel/graphql-backend` and  `react-admin-interface` directories.

Documentation is split up into three parts:
1. [Quick Start](#quick-start) -- Get setup and start working.
1. [Back End](#back-end) — GraphQL server and ORM connectivity
1. [Front End](#front-end) — The administrative UI

## Quick Start

At the moment running the admin panel interface is a manual process:

### Setup

1. install certificates into `~/.dignhy/certs`
  1.  `mkcert -cert-file graphql.portal.docker.crt -key-file graphql.portal.docker.key graphql.portal.docker`
  1.  `mkcert -cert-file admin.portal.docker.crt -key-file admin.portal.docker.key admin.portal.docker`
1. Run docker, and start the Portal using `./docker-compose up`.
6. The GraphQL playground should now be running at `https://graphql.portal.docker/graphql`
6. You should be able to read the schema at the above playground URL but specific
queries will fail unless you authenticate with the portal first. See "Portal Authentication" section below.
7. you should see the Admin interface running at https://admin.portal.docker/
8. You should see a button to authenticate with the portal.

### Portal Authentication
1. Ensure that your portal has an oauth client configured for this app.
1. the client name should be `admin-panel`, public.
1. The client should be configured with Redirect URIS matching
`https://admin.portal.docker/` and `https://admin.portal.docker/?PORTAL_URL=https://app.portal.docker`
1. Most of the configuration is done through environment variables, managed by
1. docker-compose. For the react-admin interface environment variable names must
1. start with `REACT_APP` so they get passed down to build process and packaged
1. for client delivery. To learn more about that, see the
[create-react-app documentation for custom enviroments](https://create-react-app.dev/docs/adding-custom-environment-variables)


### Using the GraphQL Playground  with JWT Auth headers:

In local development you can experiment with graphQL queries in the GraphQL
playground running at: https://graphql.portal.docker/graphql --
but you need to add HTTP Headers in the bottom left hand panel of the interface.
Just add:

```
{
  "Authorization": "Bearer <TOKEN_VALUE>"
}
```

where `TOKEN_VALUE` comes from visiting the portal JWT route when logged in as
an administrator or project admin:

`https://app.portal.docker/api/v1/jwt/portal`


### Importing Mysql Entities:

This has already been done, and you shouldn't need to do it again.
If the database schema has been substantially modified, you can import
the TypeORM entities by running this: `MYSQLPASSWORD=xyzzy npm run import`.
NOTE: You will need review these changes by hand, and re-add TypeGraphQL annotations
to any modified entities before checking them back in to git.

### Tips and Tools:

* The react-admin page (front end) is loging data access requests and responses to the
console.
* There is a chrome extension called [GraphQL Network](https://chrome.google.com/webstore/detail/graphql-network/igbmhmnkobkjalekgiehijefpkdemocm) that you can use to inspect GraphQL queries that are sent with web requests.
* There is a [JWT Debugger](https://chrome.google.com/webstore/detail/jwt-debugger/ppmmlchacdbknfphdeafcbmklcghghmd?hl=en) chrome extension you can use to debug JWT Claims

## Back End

TypeORM is used to map MySQL records into TypeScript objects. It uses annotations
to help describe the object ⟷ relation mapping. You can read the
[TypeORM Documentation](https://typeorm.io/#/) for more info.

TypeGraphQL is used to map help define GraphQL schema types using standard TypeScript definitions.
It also uses annotations one these classes and in resolvers to help describe GraphQL Resources in more detail.
You can read the [TypeGraphQL Documentation](https://typegraphql.com/docs/introduction.html) for more info.

Apollo server is used as the GraphQL server. You can read the [Apollo Server Documentation](https://www.apollographql.com/docs/apollo-server/) for more info.

Finally the web server is running an Express server to handle HTTP requests. JWT middleware
is added to the Express server to transparenetly handle portal authentication claims.

* [Documentation for TypeGraphQL](https://typegraphql.com/docs/introduction.html)
* [Documentation for TypeOrm](https://typeorm.io/#/)
* [Documentation for GraphQL](https://graphql.org/learn/)
* [Documentation for Apollo Server](https://www.apollographql.com/docs/apollo-server/)
* [Documentation for Express Server](https://expressjs.com/en/4x/api.html)
* [Documentation for Express-JWT](https://github.com/auth0/express-jwt)

## Front End

The front end uses [ReactAdmin](https://marmelab.com/react-admin/). React Admin is
an API agnostic front end that provides a complete UI Toolkit for stanrdard CRUD
operations.

React admin leaves the details of connecting to an API to a
[Data Provider](https://marmelab.com/react-admin/DataProviders.html). Data Providers
are not terribly hard to write, but to connect to our GraphQL backend, we are
using a standard pre-made DataProvider called
[ra-data-graphql-simple](https://www.npmjs.com/package/ra-data-graphql-simple)

Under the hood, ReactAdmin is using [Material UI](https://material-ui.com/) to provide
its widget set and theme support.

* [Documentation for React Admin](https://marmelab.com/react-admin/Readme.html)
* [Documentation for Material UI](https://material-ui.com/)
