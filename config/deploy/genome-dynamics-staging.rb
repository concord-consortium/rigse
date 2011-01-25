#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/genome-dynamics"
set :branch, "genome-dynamics-staging"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

after 'deploy:update_code'