#!/bin/bash
#
# Run cucumber tests
#
export RAILS_ENV=cucumber
export TEST_SUITE=ci:cucumber_search

bundle exec rake db:feature_test:prepare

bundle exec rake $TEST_SUITE
