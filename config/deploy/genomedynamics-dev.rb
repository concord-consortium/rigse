#############################################################
#  Application
#############################################################

set :deploy_to, "/web/genomedynamics.dev.concord.org"
set :branch, "genomedynamics-dev"

#############################################################
#  Servers
#############################################################

set :domain, "genomedynamics.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
