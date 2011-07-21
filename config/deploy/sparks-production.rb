#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/sparks"
set :branch, "sparks-production"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.portal.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
