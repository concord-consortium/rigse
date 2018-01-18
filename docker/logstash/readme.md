This is a customized docker image for running logstash.
It is based on the official logstash image just with the configuration
changed.

It reads data from a mysql database and outputs it to either a local ES
or a Amazon ES instance.

There are two configuration files. Only logstash.conf is built into the image.
logstash-dev.conf is intended to be used by docker-compose to override logstash.conf an
it connects to a local elasticsearch server.

*Important* If you make changes to the input or filter sections of the configuration
files, you should make the same changes to the other file.

The logstash.conf file is configured to connect to a AWS Elasticsearch domain. It uses
these environment variables:

DB_HOST - portal database hostname
DB_PORT - portal database port default 3306
DB_NAME - portal database name
DB_USER - portal database user
DB_PASSWORD - portal database password
ES_HOST - hostname of the elasticsearch domain
AWS_REGION - aws region of the aws es server


The logstash-dev.conf file is intended to be brought in by docker compose to override
the logstash.conf file that is built into the image. It uses these environment variables:

DB_HOST - portal database hostname
DB_PORT - portal database port default 3306
DB_NAME - portal database name
DB_USER - portal database user
DB_PASSWORD - portal database password
ES_HOST - hostname of the elasticsearch server
