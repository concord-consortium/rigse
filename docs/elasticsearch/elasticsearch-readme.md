# Notes on using Elasticsearch for the Portal Reports

## Setting up the ELK stack locally

Prerequisits: Java

### Elasticsearch

1. Download from https://www.elastic.co/downloads/elasticsearch
2. `cd path/to/elasticsearch-5.x.y`
   `bin/elasticsearch`
3. Test by navigating to http://localhost:9200/

For more details, see:
https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html

### Kibana

1. Download from https://www.elastic.co/downloads/kibana
2. `cd path/to/kibana-5.x.y`
   `bin/kibana`
3. Test by navigating to http://localhost:5601

### Logstash

1. Download from https://www.elastic.co/downloads/logstash
2. Copy the mysql-connector-java-5.1.41-bin.jar into `path/to/logstash-5.x.y/bin`, or
   download new version from https://dev.mysql.com/downloads/connector/j/5.1.html
3. `cd path/to/logstash-5.x.y`
4. Install JDBC plugin: `bin/logstash-plugin install logstash-input-jdbc`
5. Setup config file as described in `Running Logstash`
6. Check config: `bin/logstash -f local-mysql-pipeline.conf --config.test_and_exit`
7. Start data pipe: `bin/logstash -f local-mysql-pipeline.conf --config.reload.automatic`

## Using Elasticsearch on AWS

Look at existing instance at https://console.aws.amazon.com/es/home?region=us-east-1#has-portal-prod:dashboard

Modify the access policy as needed. Currently this is set to Deny all connections, but
when the portal needs this we can change to to allow access from the portal network.

## Running Logstash

Use one of the config files in this folder, `local-mysql-pipeline.conf` or
`has-rds-aws-es-pipeline.conf`. If using the AWS version, fill in the
aws_access_key_id and aws_secret_access_key.

Run `bin/logstash -f local-mysql-pipeline.conf --config.reload.automatic`

From a fresh start, this will take < 10 minutes to move over the HAS Production database.
Running this in the future will only move over new or changed data.

The existing ES database on AWS was populated by running Logstash on a developer machine.
If we want this data to be kept much more up to date, we should set up Logstash on
a server, and modify the `schedule` from the `jdbc` section of the configuration file.
See [here](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html)
for scheduling.
