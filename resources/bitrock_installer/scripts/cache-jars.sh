#!/bin/sh

source "$(dirname $0)/../jnlps.conf"

FIRST_URL=""
count=0
for i in $JNLP_URLS 
do 
  java -Djnlp2shell.verbose=true -cp `dirname $0`/jnlp2shell.jar org.concord.JnlpCacher $i  jars
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
