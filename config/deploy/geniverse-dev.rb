#############################################################
#  Application
#############################################################

set :deploy_to, "/web/geniverse-portal.dev.concord.org"
set :branch, "geniverse-dev"

set :user, "geniverse"

#############################################################
#  Servers
#############################################################

set :domain, "geniverse-portal.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
