#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/geniverse-portal"
set :branch, "geniverse"

#############################################################
#  Servers
#############################################################

set :domain, "geniverse-portal.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
