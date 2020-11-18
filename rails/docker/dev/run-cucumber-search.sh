#!/bin/bash

#
# Prepare the cucumber database by checking if there are migrations not
# run on the development database,
# then loading the schema.rb into the cucumber database
#
bundle exec rake db:feature_test:prepare

#
# Run cucumber tests
#
RAILS_ENV=cucumber bundle exec rake ci:cucumber_search
