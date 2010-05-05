#############################################################
#  Application
#############################################################

set :deploy_to, "/web/has.dev.concord.org"
set :branch, "has-dev"

#############################################################
#  Servers
#############################################################

set :domain, "has.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
