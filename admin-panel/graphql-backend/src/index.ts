import "reflect-metadata";
import express from "express"
import { createConnection } from "typeorm";
import { ApolloServer  } from "apollo-server-express";
import { buildSchema, AuthChecker} from "type-graphql";
import { AdminProjectResolver } from "./resolvers/AdminProjectResolver"
import { AdminProjectUserResolver } from "./resolvers/AdminProjectUserResolver"
import { UserResolver } from "./resolvers/UserResolver"
import jwt from "express-jwt";
import { Config } from "./config"
import { ApolloServerPlugin } from "apollo-server-plugin-base";
import { GraphQLRequestContext } from "apollo-server-types";


interface IPortalClaims {
  project_admins: number[]
  admin: 1|-1
}

// eslint-disable-next-line
type AnyForNow = any

interface MyContextType {
  request: AnyForNow
  user: IPortalClaims;
}

const customAuthChecker: AuthChecker<MyContextType> = ({context} /*, roles */) => {
  if (context.user.admin === 1) {
    return true
  }
  return false
}

const loggingPlugin: ApolloServerPlugin = {
  // Fires whenever a GraphQL request is received from a client.
  requestDidStart(requestContext: GraphQLRequestContext<MyContextType>) {
    console.log('Request started! Query:\n')
    console.dir(requestContext)
  }
}

const path = '/graphql'
const app = express();

async function main() {
  // Connect to TypeOrm DB
  await createConnection()
  const schema = await buildSchema({
    nullableByDefault: true,
    emitSchemaFile: true,
    resolvers: [UserResolver, AdminProjectResolver, AdminProjectUserResolver],
    authChecker: customAuthChecker
  })

  const server = new ApolloServer({
    schema,
    plugins: [loggingPlugin],
    context: ({ req } ) => {
      const context:MyContextType = {
        request: req,
        // eslint ignore-next-line
        user: (req as any).user, // `req.user` comes from `express-jwt`
      };
      console.log(context.user)
      return context;
    },
  });

  // Mount a jwt authentication middleware that is run before the GraphQL execution
  app.use(
    path,
    jwt(Config.jwtConfig)
  );


  // Apply the GraphQL server middleware
  server.applyMiddleware({ app, path});
  // Launch the express server
  app.listen({ port: 4000 }, () =>
    console.log(`🚀 Server ready at http://localhost:4000${server.graphqlPath}`),
  );
  console.log("Server has started!")
}


main()
