# learn production branch
set :user, "deploy"
set :domain, "learn.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "master"
