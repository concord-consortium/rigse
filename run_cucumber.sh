#!/bin/sh

Xvfb :99 -ac -screen 0 1920x1080x24 &

PID=$!

export DISPLAY=:99
export RAILS_ENV=cucumber

bundle exec spring rake cucumber

kill $PID
