#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/geniverse.portal"
set :branch, "geniverse-production"

set :user, "geniverse"

#############################################################
#  Servers
#############################################################

set :domain, "geniverse.portal.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
