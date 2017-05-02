#!/bin/bash
#
# Start the docker solr-test service with a test core 
# and allow additional arguments passed to actual solr script rather than 
# docker-entrypoint.sh wrapper.
#

cd /opt/solr

CONFIG_SOURCE="/opt/solr/rigse-solr-docker/sunspot"
coresdir="/opt/solr/server/solr/mycores"
mkdir -p $coresdir

create_core () {
  coredir="$coresdir/$1"
  if [ ! -d $coredir ]; then
      cp -r $CONFIG_SOURCE/ $coredir
      chown solr:solr $coredir
      touch "$coredir/core.properties"
      echo created "$1"
  else
      echo "core $1 already exists"
  fi
}

create_core test

solr $*
