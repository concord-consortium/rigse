#############################################################
#  Application
#############################################################

set :deploy_to, "/web/genome-dynamics.dev.concord.org"
set :branch, "genomedynamics-dev"

#############################################################
#  Servers
#############################################################

set :domain, "genome-dynamics.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
