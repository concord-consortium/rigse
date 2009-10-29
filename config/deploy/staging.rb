#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/rites"
set :branch, "staging"

#############################################################
#  Servers
#############################################################

set :domain, "bumblebeeman.concord.org"
server domain, :app, :web
# role :db, domain, :primary => true
