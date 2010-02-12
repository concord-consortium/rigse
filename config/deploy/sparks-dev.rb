#############################################################
#  Application
#############################################################

set :deploy_to, "/web/sparks.dev.concord.org"
set :branch, "sparks"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
