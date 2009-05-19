#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/rites-investigations"

#############################################################
#  Servers
#############################################################

set :domain, "rites-investigations.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
