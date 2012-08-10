# interactions staging branch
set :user, "deploy"
set :domain, "aws-staging.interactions.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
set :branch, "interactions-staging"
