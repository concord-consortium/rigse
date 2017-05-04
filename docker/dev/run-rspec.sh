#!/bin/bash
#
# Run rspec tests in docker environment.
#

#
# Prepare spec tests
#
bundle exec rake db:test:prepare

#
# Run spec tests
#
bundle exec rspec spec/

