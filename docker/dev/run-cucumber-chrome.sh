#!/bin/bash

#
# Run cucumber tests
#
export RAILS_ENV=cucumber
export TEST_SUITE=ci:cucumber_javascript

bundle exec rake db:schema:load
bundle exec rake db:migrate
bundle exec rake db:test:prepare

bundle exec rake $TEST_SUITE


