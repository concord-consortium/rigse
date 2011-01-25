#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/genome-dynamics"
set :branch, "genome-dynamics-production"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

after 'deploy:update_code'