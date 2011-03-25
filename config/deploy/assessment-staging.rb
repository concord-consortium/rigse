#############################################################
#  Application
#############################################################

set :deploy_to, "/web/assessment"
set :branch, "assessment-staging"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm3.concord.org"
server domain, :app, :web
role :db, "seymour.concord.org", :primary => true
