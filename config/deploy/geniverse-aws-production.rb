# geniverse aws production
set :user, "deploy"
set :deploy_to, "/web/portal"
role :app, "geniverse1.concord.org", "geniverse2.concord.org", "geniverse3.concord.org", "geniverse4.concord.org", "geniverse5.concord.org"
role :web, "geniverse1.concord.org", "geniverse2.concord.org", "geniverse3.concord.org", "geniverse4.concord.org", "geniverse5.concord.org"
role :db, "geniverse1.concord.org", :primary => true
set :branch, "master"

set :asset_env, "RAILS_GROUPS=assets RAILS_RELATIVE_URL_ROOT=/portal"
default_environment['PORTAL_FEATURES'] = "geniverse_wordpress geniverse_remote_auth"