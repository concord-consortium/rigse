#!/bin/bash

# This script is intended to be run inside of a development Docker container.
# In the production environment a different script is used:
#   docker/prod/run.sh

DB_CONFIG=$APP_HOME/config/database.yml
SETTINGS=$APP_HOME/config/settings.yml
ENV_VARS=$APP_HOME/config/app_environment_variables.rb
PIDFILE=$APP_HOME/tmp/pids/server.pid

if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

bundle check || bundle install

if [ ! -f $SETTINGS ]; then
  cp $APP_HOME/config/settings.sample.yml $SETTINGS
fi

if [ ! -f $ENV_VARS ]; then
  cp $APP_HOME/config/app_environment_variables.sample.rb $ENV_VARS
fi

if [ ! -f $DB_CONFIG ]; then
  cp $APP_HOME/config/database.sample.yml $DB_CONFIG
  # Setup DB when this script is run for the first time.
  bundle exec rake db:setup
fi

if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rake assets:precompile
fi

bundle exec rails s -b 0.0.0.0
