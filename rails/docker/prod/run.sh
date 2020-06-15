#!/bin/bash

APP_NAME='rigse'

# When docker stops or restarts the container sometimes these pid files are left around
PIDFILE=/$APP_NAME/tmp/pids/server.pid
if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

UNICORNPIDFILE=/$APP_NAME/tmp/unicorn.pid
if [ -f $UNICORNPIDFILE ]; then
  rm $UNICORNPIDFILE
fi


bundle exec rake db:create

if [ "$1" == "migrate" ]; then
  bundle exec rake db:migrate
fi

foreman start -d /rigse -f /$APP_NAME/docker/prod/Procfile
