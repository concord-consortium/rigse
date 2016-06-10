# NOTE: this runs within the solr docker container which has /rigse mapped to the rigse files

cd /opt/solr

CONFIG_SOURCE="/rigse/solr/configsets/sunspot"
coresdir="/opt/solr/server/solr/mycores"
mkdir -p $coresdir

function create_core {
  coredir="$coresdir/$1"
  if [[ ! -d $coredir ]]; then
      cp -r $CONFIG_SOURCE/ $coredir
      touch "$coredir/core.properties"
      echo created "$1"
  else
      echo "core $1 already exists"
  fi
}

create_core mycore
create_core development

docker-entrypoint.sh solr
