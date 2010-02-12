#############################################################
#  Application
#############################################################

set :deploy_to, "/web/sg.dev.concord.org"
set :branch, "master"

#############################################################
#  Servers
#############################################################

set :domain, "sg.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
