#!/bin/bash

#
# Set up and run Xvfb (X virtual framebuffer)
# This allows us to run headless X applications in docker. E.g. firefox.
#
export XVFB_LOG=/tmp/xvfb.docker.log
export DISPLAY=:99

pkill Xvfb
Xvfb $DISPLAY -ac 2>&1 -screen 0 1920x1080x16 >> $XVFB_LOG &

#
# Run cucumber tests
#
export RAILS_ENV=cucumber
export TEST_SUITE=ci:cucumber_search

bundle exec rake db:schema:load
bundle exec rake db:migrate
bundle exec rake db:test:prepare

bundle exec rake $TEST_SUITE


