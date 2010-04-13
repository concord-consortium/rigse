#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/has"
set :branch, "has-staging"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
