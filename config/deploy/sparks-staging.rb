#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/sparks"
set :branch, "sparks"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.portal.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
