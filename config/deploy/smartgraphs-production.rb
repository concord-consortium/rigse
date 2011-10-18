#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/smartgraphs.portal"
set :branch, "smartgraphs-production"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
