#############################################################
#  Application
#############################################################

set :application, "sparks-portal"
set :deploy_to, "/web/production/sparks"
set :branch, "sparks"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.portal.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
