#!/usr/bin/env bash

# Run rspec tests in docker environment:
#   – Execute like this: `docker compose run --rm app ./docker/dev/run-spec.sh`
#   – Or make an alias `alias dspec='docker compose run --rm app ./docker/dev/run-spec.sh'`
#        then type `dspec` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker compose run --rm app bash` … ./docker/dev/run-spec.sh`)

#
# Prepare spec tests
#

bundle exec rake db:test:prepare

#
# Prepare the cucumber database:
#  - checking if there are migrations not run on the development database
#  - drop cucumber database
#  - create cucumber database
#  - load schema.rb into cucumber database
#
bundle exec rake db:feature_test:prepare

#
# Add users, students, teachers, classes, resources, and assignments
#
RAILS_ENV=cucumber bundle exec rake app:setup:create_default_data

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
