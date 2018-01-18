# Notes on using Elasticsearch for the Portal Reports

The Portal Researcher report system uses Elasticsearch to find the student data to be
reported on. When a report is run it currently pulls data directly from the database
not Elasticsearch.

The Elasticsearch service is kept up-to-date using logstash.  Logstash periodically scans
mysql for changes and then sends those changes to Elasticsearch.

The docker-compose.yml takes care of setting a docker container with elasticsearch and
logstash locally. Additionally to help with debugging the Elasticsearch container includes
Kibana. Kibana is a UI for searching and displaying data in Elasticsearch.  These 3
components together are called the ELK stack.

When the portal is run in AWS. An AWS managed Elasticsearch domain is used instead of a
docker container. Logstash is run as a docker container.

If you don't want to use docker to manage all of this, below are some untested directions
for setting the ELK stack locally.

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
6. Check config: `bin/logstash -f docker/logstash/logstash-dev.conf --config.test_and_exit`
7. Start data pipe: `bin/logstash -f docker/logstash/logstash-dev.conf --config.reload.automatic`

## Running Logstash

Use one of the config files in, `docker/logstash` look at the readme in that folder to
see the environment variables the configuration file requires.

Run `bin/logstash -f docker/logstash/logstash-dev.conf --config.reload.automatic`

From a fresh start, if you have a large local database it could take 10 minutes to move
over the data. Running this in the future will only move over new or changed data.
