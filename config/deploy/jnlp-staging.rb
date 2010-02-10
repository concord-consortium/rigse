#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/rites-jnlp"
set :branch, "master"

#############################################################
#  Servers
#############################################################

set :domain, "seymour.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
