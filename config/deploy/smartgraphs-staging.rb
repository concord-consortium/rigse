#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/smartgraphs"
set :branch, "smartgraphs-staging"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
