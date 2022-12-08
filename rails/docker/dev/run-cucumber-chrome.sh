#!/usr/bin/env bash

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

#
# Run cucumber tests
#
RAILS_ENV=cucumber bundle exec rake ci:cucumber_javascript
