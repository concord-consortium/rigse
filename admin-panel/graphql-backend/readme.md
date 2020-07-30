
# portal-admin-spike

Experimental external Portal administration graphQL service.
For more specifics about this spikes goals, see this
[Google Design Document](https://docs.google.com/document/d/1uq8jXhpw96FYXn2dqNZIl1XUjVc3S3h2P2lfD7RMoUw/edit).

This work is being tracked in this [PT Story](https://www.pivotaltracker.com/story/show/172782125)

## Development

This directory is for the backend GraphQL server.

### Setup
1. Run docker, and start the Portal using docker-compose up.
2. Copy `./sample-ormconfig.json` to `./orgmconfig.json`
3. Modify `./ormconfig.json` to use the database and credentials used in Portal.
4. run `npm install` in this directory
5. run `npm run start` from this directory
6. you should see the GraphQL playground running at http://localhost:4000/graphql
5. cd into `react-admin` directory and run `npm install`
6. in `react-admin` run `npm run start`
7. you should see the Admin interface running at http://localhost:3000/

### Portal Authentication

1. Ensure that your portal has an oauth client configured for this app.
1. Configure this apps Poral URL and Oauth Secret using environment variables
1. Developers can set this by copying `/.env-sample`, and adjusting to taste
1. You can specify the poral URL and portal Secret via query params.
`PORTAL_URL` and `OATUH_CLIENT_NAME`


### Importing Mysql entities:

This has already been done, and you shouldn't need to do it again:
* To import typescript entities use: `MYSQLPASSWORD=xyzzy npm run import`