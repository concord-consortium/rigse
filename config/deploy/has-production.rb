#############################################################
#  Application
#############################################################

set :deploy_to, "/web/portal"
set :branch, "topic_au_rationale"

#############################################################
#  Servers
#############################################################

set :domain, "has.portal.concord.org"
server domain, :app, :web
role :db, domain, :primary => true

# this currently isn't used, instead the files are proxied back to seymour
namespace :deploy do
  desc "link in the has resources folder"
  task :has_resource_symlink do
    run "ln -nfs #{shared_path}/public/resources #{release_path}/public/resources"
  end
end

after 'deploy:update_code', 'deploy:has_resource_symlink'