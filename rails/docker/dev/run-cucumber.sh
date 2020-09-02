#!/bin/bash
#
# Run cucumber tests in docker environment.
#

#
# Prepare cucumber tests
#
RAILS_ENV=feature_test bundle exec rake db:create
bundle exec rake db:feature_test:prepare

#
# Run cucumber tests
#
bundle exec rake ci:cucumber_without_javascript
