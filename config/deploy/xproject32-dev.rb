# rails3.0 development branch
set :user, "deploy"
set :domain, "xproject32.dev.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "asset_pipeline"
