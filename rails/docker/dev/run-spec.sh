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

bundle exec rake db:test:prepare

bundle exec rake db:feature_test:prepare

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
