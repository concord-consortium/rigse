#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/rites-investigations"

#############################################################
#  Servers
#############################################################

set :domain, "rites-investigations.concord.org"
server domain, :app, :web
role :db, domain, :primary => true