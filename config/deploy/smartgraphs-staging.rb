#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/smartgraphs"
set :branch, "master"

#############################################################
#  Servers
#############################################################

set :domain, "smartgraphs.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
