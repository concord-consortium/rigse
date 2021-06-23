# Notes on using Elasticsearch for the Portal Reports

The Portal Researcher report system uses Elasticsearch to find the student data to be
reported on. When a report is run it currently pulls data directly from the database
not Elasticsearch.

The Elasticsearch service is kept up-to-date by pushing learner objects to the database
each time a learner is created changes. There is also a rake task,
app:report:update_elastic_search_learners, which will find all learners and push them
to the database.

The docker-compose.yml takes care of setting a docker container with elasticsearch locally.
Additionally to help with debugging the Elasticsearch container includes Kibana. Kibana is
a UI for searching and displaying data in Elasticsearch.

Typically a third application, Logstash, is used to pipe data from the Rails DB to the
ES database, but because we are updating the ES DB by hand, this isn't needed. When
Elasticsearch, Logstash and Kibana are used together this is called the ELK stack.

When the portal is run in AWS. An AWS managed Elasticsearch domain is used instead of a
docker container.

If you don't want to use docker to manage all of this, below are some untested directions
for setting the E(L)K stack locally.

## Setting up the E(L)K stack locally

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

