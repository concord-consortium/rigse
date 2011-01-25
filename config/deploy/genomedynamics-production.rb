#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/genomedynamics"
set :branch, "genomedynamics-production"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

after 'deploy:update_code'