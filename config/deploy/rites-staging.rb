#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/rites-investigations"
set :branch, "rites-staging"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
