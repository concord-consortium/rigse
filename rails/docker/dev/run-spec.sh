#!/bin/bash
#
# Run rspec tests in docker environment:
#   – Execute like this: `docker-compose run --rm app ./docker/dev/run-spec.sh`
#   – Or make an alias `alias dspec='docker-compose run --rm app ./docker/dev/run-spec.sh'`
#        then type `dspec` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker-compose run --rm bash` … ./docker/dev/run-psec.sh`)

#
# Prepare spec tests
#

export RAILS_ENV=test
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:test:prepare

RAILS_ENV=feature_test bundle exec rake db:create
RAILS_ENV=feature_test bundle exec rake db:schema:load
RAILS_ENV=feature_test bundle exec rake db:test:prepare

if [ "$1" == "setup" ]; then
    echo 
    echo "Spec test setup completed." 
    echo 
    exit 0
fi

#
# Run spec tests
#
bundle exec rspec spec/

