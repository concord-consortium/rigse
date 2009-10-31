#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/rites-investigations"
set :branch, "production"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

