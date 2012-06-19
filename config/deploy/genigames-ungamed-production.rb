# genigames ungamed
set :user, "deploy"
set :domain, "ungamed.genigames.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "gv-r32"
