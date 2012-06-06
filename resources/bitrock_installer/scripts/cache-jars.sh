#!/bin/sh

source "$(dirname $0)/../jnlps.conf"

FIRST_URL=""
count=0

CDN=""
if [ "$JNLP_CDN_MIRROR" != "" ]; then
  CDN="-Djnlp2shell.mirror_host=$JNLP_CDN_MIRROR"
fi

STATIC_WWW=""
if [ "$USE_STATIC_WWW" != "" ]; then
  STATIC_WWW="-Djnlp2shell.static_www=$USE_STATIC_WWW"
fi

for i in $JNLP_URLS 
do 
  CMD="java -Djnlp2shell.verbose=true -cp `dirname $0`/jnlp2shell.jar $CDN $STATIC_WWW org.concord.JnlpCacher $i jars"
  echo "running command: $CMD"
  `$CMD`
  if [ "$count" -eq "0" ]; then
    FIRST_URL=$i
  fi 
  let "count += 1" 
done

# to be safe only set the jnlp_url if their is only one jnlp.
if [ "$count" -eq "1" ]; then
  [ ! -e properties ] && mkdir properties 
  echo "installation_jnlp=$FIRST_URL" > properties/jnlp_url.properties
fi
