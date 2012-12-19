set :user, "deploy"
set :domain, "interactions.portal.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "master"
