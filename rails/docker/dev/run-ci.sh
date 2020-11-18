#!/bin/bash
#
# Run rspec tests in docker environment:
#   – Execute like this: `docker-compose run --rm app ./docker/dev/run-ci.sh`
#   – Or make an alias `alias dci='docker-compose run --rm app ./docker/dev/run-ci.sh'`
#        then type `dci` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker-compose run --rm bash` … ./docker/dev/run-ci.sh`)

#
# Prepare the test database by checking if there are migrations not
# run on the development database,
# then droping the existing test database
# and loading the schema.rb into the test database
#
bundle exec rake db:test:prepare

#
# Run spec tests
#
RAILS_ENV=test bundle exec guard
