#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/rites"
set :branch, "production"

#############################################################
#  Servers
#############################################################

set :domain, "bumblebeeman.concord.org"
server domain, :app, :web
# role :db, domain, :primary => true
