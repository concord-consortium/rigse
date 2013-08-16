# geniverse aws testing
set :user, "deploy"
set :domain, "geniverse.testing.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "master"

set :asset_env, "RAILS_GROUPS=assets RAILS_RELATIVE_URL_ROOT=/portal"
default_environment['PORTAL_FEATURES'] = "geniverse_wordpress geniverse_remote_auth"