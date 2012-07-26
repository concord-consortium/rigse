load File.join(File.dirname(__FILE__), './sparks-common.rb')

#############################################################
#  Connection:
#############################################################
set :gateway, "otto.concord.org"

#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "sparks-production"

#############################################################
#  Servers
#############################################################

set :domain, "ruby-vm7.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
