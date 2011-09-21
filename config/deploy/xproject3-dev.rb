# rails3.0 development branch
set :user, "deploy3"
set :domain, "xproject3.dev.concord.org"
set :deploy_to, "/web/xproject3.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "rails3.0"
