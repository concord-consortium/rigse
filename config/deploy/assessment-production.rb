#############################################################
#  Application
#############################################################

set :deploy_to, "/web/assessment"
set :branch, "assessment-production"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm4.concord.org"
server domain, :app, :web
role :db, "seymour.concord.org", :primary => true
