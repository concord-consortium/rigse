#############################################################
#  Application
#############################################################

set :deploy_to, "/web/smartgraphs.dev.concord.org"
set :branch, "smartgraphs-dev"

#############################################################
#  Servers
#############################################################

set :domain, "smartgraphs.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
