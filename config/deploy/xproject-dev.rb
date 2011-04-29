# RITES development branch
set :domain, "xproject.dev.concord.org"
set :deploy_to, "/web/xproject.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "master"
