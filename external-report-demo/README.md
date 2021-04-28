# External Report Demo

This creates a very simple demo report that simply lists the parameters that were sent to the report by the report filter page.

This external report runs as a Lambda application on AWS, built using the SAM (Serverless Application Model) CLI.

To build and deploy you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Node.js - [Install Node.js 12+](https://nodejs.org/en/), including the NPM package management tool.

After installing, the application can be built using

```bash
sam build
```

and deployed with

```bash
sam deploy --guided
```

## Local testing

Sam uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

You can test the function on the command line with

```bash
sam local invoke "DemoReportFunction" -e events/learner-report.json
sam local invoke "DemoReportFunction" -e events/user-report.json
```

You can launch the service on a local server with

```bash
sam local start-api
```

## HMAC secret

In order to validate that the requests from the report portal haven't been modified, the portal's queries are signed with a secret key, `JWTHMACSecret`. This report needs the same key to be able to compare the signatures.

This key can be found in AWS -> Cloud Formation -> Stacks -> [Stack name, e.g. learn-ecs-staging] -> Parameters.

During the guided deployment, you will be asked if you want to paste in this key. You can do so, but be aware that if you tell the guided deployment to write the configs to a .toml file, it will add this key, so don't commit it.

You can also add or modify this parameter after deployment by finding the function in AWS -> Lambda -> Functions and adding it to Configuration -> Environment Variables.

For local testing, you can add the secret to `template.yml` so long as it is not committed.
