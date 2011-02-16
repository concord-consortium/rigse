#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/genomedynamics"
set :branch, "genomedynamics-staging"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
