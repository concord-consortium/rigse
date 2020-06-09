import "reflect-metadata";
import express, { request, Request } from "express"
import { createConnection } from "typeorm";
import { ApolloServer  } from "apollo-server-express";
import { buildSchema, AuthChecker} from "type-graphql";
import { AdminProjectResolver } from "./resolvers/AdminProjectResolver"
import { AdminProjectUserResolver } from "./resolvers/AdminProjectUserResolver"
import { UserResolver } from "./resolvers/UserResolver"
import jwt from "express-jwt";
import { Config } from "./config"


interface IPortalClaims {
  project_admins: number[]
  admin: 1|-1
}
interface MyContextType {
  request: any;
  user: IPortalClaims;
}

const customAuthChecker: AuthChecker<MyContextType> = ({context}, roles) => {
  if (context.user.admin === 1) {
    return true
  }
  return false
}

const loggingPlugin = {
  // Fires whenever a GraphQL request is received from a client.
  requestDidStart(requestContext: any) {
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
        user: (req as any).user, // `req.user` comes from `express-jwt`
      };
      console.log(context.user)
      return context;
    },
  });

    // Mount a jwt or other authentication middleware that is run before the GraphQL execution
  app.use(
    path,
    jwt({
      secret: Config.jwtSecret ||"",
      // We need to be able to get the schema without credentials:
      credentialsRequired: false
    }),
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
