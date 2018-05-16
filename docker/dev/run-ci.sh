#!/bin/bash
#
# Run rspec tests in docker environment:
#   – Execute like this: `docker-compose run --rm app ./docker/dev/run-ci.sh`
#   – Or make an alias `alias dci='docker-compose run --rm app ./docker/dev/run-ci.sh'`
#        then type `dci` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker-compose run --rm bash` … ./docker/dev/run-ci.sh`)
export XVFB_LOG=/tmp/xvfb.docker.log
export DISPLAY=:99

pkill Xvfb
Xvfb $DISPLAY -ac 2>&1 -screen 0 1920x1080x16 >> $XVFB_LOG &

#
# Prepare spec tests
#
export RAILS_ENV=test
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:test:prepare

#
# Run spec tests
#
bundle exec guard

