# learn production branch
set :user, "deploy"
set :domain, "learn.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "master"

default_environment['PORTAL_FEATURES'] = "geniverse_remote_auth genigames_data geniverse_backend allow_cors"
