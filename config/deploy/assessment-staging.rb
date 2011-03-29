#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "assessment-staging"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm3.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
