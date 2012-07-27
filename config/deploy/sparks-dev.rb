load File.join(File.dirname(__FILE__), './sparks-common.rb')

#############################################################
#  Application
#############################################################

set :deploy_to, "/web/sparks.dev.concord.org"
set :branch, "sparks-dev"

#############################################################
#  Servers
#############################################################

set :domain, "sparks.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
