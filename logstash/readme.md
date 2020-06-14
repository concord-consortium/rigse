This is a customized docker image for running logstash.
It is based on the official logstash image just with the configuration
changed.

It reads data from a mysql database and outputs it to either a local ES
or a Amazon ES instance.

There are three configuration files.
logstash.conf - this contains the mysql input config and the filter config
logstash-output.conf - this contains the aws elasticsearch output config
logstash-output-dev.conf - this contains the local elasticsearch output config

logstash.conf and logstash-output.conf are built into image made by the Dockerfile.
The docker-compose file at the top level of this repo then overrides logstash-output
when docker-compose is used to run this locally.

The config files uses these environment variables:

DB_HOST - portal database hostname
DB_PORT - portal database port default 3306
DB_NAME - portal database name
DB_USER - portal database user
DB_PASSWORD - portal database password
ES_HOST - hostname of the elasticsearch domain
AWS_REGION - aws region of the aws es server
