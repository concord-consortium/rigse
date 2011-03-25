#############################################################
#  Application
#############################################################

set :deploy_to, "/web/assessment.dev.concord.org"
set :branch, "assessment-dev"

#############################################################
#  Servers
#############################################################

set :domain, "assessment.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
