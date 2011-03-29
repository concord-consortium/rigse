#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "assessment-production"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm4.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
