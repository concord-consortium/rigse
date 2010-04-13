#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/has"
set :branch, "has"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
