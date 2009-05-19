set :domain, "rites.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

set :branch, "master"