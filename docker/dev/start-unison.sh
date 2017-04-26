#!/bin/bash

# the first time you use this you probably want to bring up the unison container
# first by doing `docker-compose up unison` then run this file to start the sync
# otherwise the source files won't be implace before the application starts up

# to run this on OS X you need to install unison and also install the unox watcher:
# https://github.com/onnimonni/docker-unison#installing-unison-fsmonitor-on-osx-unox

port=$(docker-compose port unison 5000 | awk -F: '{print $NF}')
echo Connecting to unison on port: $port
unison . socket://localhost:$port/ -repeat watch -auto -batch
