# genigames ungamed
set :user, "deploy"
set :deploy_to, "/web/portal"
set :domain, "genigames.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "gv-r32"

set :asset_env, "RAILS_GROUPS=assets RAILS_RELATIVE_URL_ROOT=/portal"
