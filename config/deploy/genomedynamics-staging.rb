#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/genome-dynamics"
set :branch, "genomedynamics-dev"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
