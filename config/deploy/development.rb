#############################################################
#  Application
#############################################################

set :deploy_to, "/web/production/itsisu_investigations"
set :branch, "itsi-master"

#############################################################
#  Servers
#############################################################

set :domain, "itsisu_investigations.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
