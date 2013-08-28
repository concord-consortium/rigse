# genigames baseline
set :user, "deploy"
set :domain, "baseline.genigames.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "gv-r32"

set :asset_env, "RAILS_GROUPS=assets RAILS_RELATIVE_URL_ROOT=/portal"