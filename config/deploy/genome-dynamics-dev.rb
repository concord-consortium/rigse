#############################################################
#  Application
#############################################################

set :deploy_to, "/web/genome-dynamics.dev.concord.org"
set :branch, "genome-dynamics-dev"

#############################################################
#  Servers
#############################################################

set :domain, "genome-dynamics.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

after 'deploy:update_code'