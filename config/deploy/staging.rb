#############################################################
#  Application
#############################################################

set :deploy_to, "/web/staging/rites-investigations"
set :branch, "dataservice_rails_2_3_3_portal_staging"

#############################################################
#  Servers
#############################################################

set :domain, "rites-investigations.staging.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
