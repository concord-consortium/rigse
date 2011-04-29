#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/sparks"
set :branch, "sparks-staging"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
