#!/bin/bash

# This script is intended to be run inside of a development Docker container.
# In the production environment a different script is used:
#   docker/prod/run.sh

DB_CONFIG=$APP_HOME/config/database.yml
PIDFILE=$APP_HOME/tmp/pids/server.pid

if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

if [ ! -f $DB_CONFIG ]; then
  cp $APP_HOME/config/database.sample.yml $DB_CONFIG
fi

bundle check || bundle install

bundle exec rake sunspot:solr:start
