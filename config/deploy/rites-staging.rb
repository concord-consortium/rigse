#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "rites-staging-rails3"
set :gateway, "otto.concord.org"

#############################################################
#  Servers
#############################################################

set :domain, "63.138.119.196"
server domain, :app, :web
role :db, domain, :primary => true
