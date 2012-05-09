# interactions staging branch
set :user, "deploy"
set :gateway, "otto.concord.org"
set :domain, "63.138.119.195" # ruby-vm12
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "interactions-staging"
