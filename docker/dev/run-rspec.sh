#!/bin/bash
#
# Run rspec tests in docker environment.
#

#
# Prepare spec tests
#
rake db:schema:load
rake db:migrate
rake db:test:prepare

#
# Run spec tests
#
RAILS_ENV=test rake spec

