# genigames ungamed
set :user, "deploy"
set :deploy_to, "/web/portal"
set :domain, "genigames.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "gv-r32"
