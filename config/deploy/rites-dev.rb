# RITES development branch
set :domain, "rites.dev.concord.org"
set :deploy_to, "/web/rites.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "rites-dev"