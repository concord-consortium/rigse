#############################################################
# Transport: for vm hosts, we need to connect inside CC
#############################################################
set :gateway, "otto.concord.org"

#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging"
set :branch, "smartgraphs-staging"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm7.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
