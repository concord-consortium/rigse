#!/bin/bash
#
# Run cucumber tests in docker environment.
#

#
# Prepare cucumber tests
#
RAILS_ENV=cucumber bundle exec rake db:create
RAILS_ENV=cucumber bundle exec rake db:schema:load
bundle exec rake db:test:prepare_cucumber

#
# Run cucumber tests
#
bundle exec rake ci:cucumber_without_javascript


