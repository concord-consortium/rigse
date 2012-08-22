#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "sg"

#############################################################
#  Servers
#############################################################

set :domain, "aws1.smartgraphs.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
